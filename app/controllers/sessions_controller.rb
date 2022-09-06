class SessionsController < ApplicationController

    #skip_before_filter :verify_authenticity_token

    skip_before_filter :session_expiry
    skip_before_filter :update_session_expiration
    skip_before_filter :verify_traffic

    def show
        store_last_location
        @is_signed_in = signed_in?
        expire_time = session[:expires_at] || Time.now
        @session_time_left = (expire_time - Time.now).to_i
        if @is_signed_in && @session_time_left <= 0
            @is_signed_in = false
        end
    end

    def new
        flash[:error] = "Please login"
        redirect_to root_path
    end

    def create
        @email = params[:session][:email].strip.downcase
        user = User.find_by_email(@email)

        if user.nil?
            redirect_to root_path, :flash => {:error => "Invalid email/password combination"}
            return
        end

        if user.invalid_login_attempts >= 20
            redirect_to root_path(email: @email), :flash => {:error => "Your account is locked. Please contact support."}
            return
        end

        if user.authenticate(params[:session][:password].strip)
            response.headers['X-CSRF-Token'] = form_authenticity_token
            respond_to do |format|
                format.html {
                    if user.create_password?
                        flash[:success] = "Please create a password"
                        redirect_to update_password_path(email: user.email, new_account: true)
                    else
                        sign_in(user, params[:session]["stay_logged_in"] == "1")
                        if user.elephant_admin?
                            redirect_to admin_path
                        else
                            redirect_back_or root_path
                        end
                    end
                }
                format.js {
                    sign_in(user, params[:session]["stay_logged_in"] == "1")
                    @is_signed_in = true
                    render 'sessions/show'
                }
                format.xml {
                    render xml: user,
                           :methods => [:api_key],
                           except: [:created_at, :updated_at, :password_digest, :remember_token, :elephant_admin, :create_password, :unverified_network, :verified_networks, :network_access_code, :accepted_tou]
                }
            end
        else
            user.update_attribute(:invalid_login_attempts, user.invalid_login_attempts + 1)

            respond_to do |format|
                format.html {
                    redirect_to root_path, :flash => {:error => "Invalid email/password combination"}
                }
                format.xml {
                    render :nothing => true, :status => :unauthorized
                }
            end
        end
    end

    def destroy
        sign_out
        redirect_to root_url
    end

    def edit
        @email = params[:email]
        @new_account = params[:new_account] == 'true'
        @current_password = params[:current_password]
    end

    def update

        @new_account = params[:session][:new_account]
        params[:session].delete(:new_account)

        @current_password = params[:session][:current_password]
        if @current_password.present?
            @current_password = @current_password.strip
        end
        params[:session].delete(:current_password)

        @email = params[:session][:email]
        if @email.present?
            @email = @email.downcase.strip
        end
        user = User.find_by_email(@email)
        if user && user.authenticate(@current_password)
            user.password = params[:session][:password]
            user.password_confirmation = params[:session][:password_confirmation]
            user.create_password = false
            if user.save
                flash[:success] = "Password updated"
                sign_in(user, true)
                redirect_to root_path
            elsif user.password != user.password_confirmation
                flash[:error] = "Passwords do not match"
                render :edit
            else
                flash[:error] = user.errors.full_messages.join(', ').html_safe
                render :edit
            end
        else
            flash[:error] = "Invalid email/password combination"
            render :edit
        end
    end

    def reset_password
        if params[:session]
            @email = params[:session][:email].strip.downcase
            @user = User.find_by_email(@email)

            if @user
                password = SecureRandom.urlsafe_base64[1..7]
                @user.password = password
                @user.password_confirmation = password
                @user.create_password = true

                if @user.save
                    @user.delay.send_reset_password_email(password)

                    render 'sessions/reset_password'
                    return
                end
            end
        end
    end

    def verify_network
        if params[:session]
            if params[:session][:network_access_code]
                if authorize_network_code params[:session][:network_access_code].strip
                    redirect_to root_path
                    return
                else
                    render 'verify_network', :flash => {:error => "Network code invalid. Please try again."}
                end
            end
        elsif params[:resend] and params[:resend] == "true"
            verify_traffic true
            session[:return_to] = root_path
        end
    end

    # authenticate user with user id and api key for desktop app & data layer
    def authenticate_user
        message = ''
        if params[:user_id] && params[:access_token]
            user = User.find(params[:user_id])

            if user.present?
                access_token = params[:access_token]

                api_key = ApiKey.find_by_access_token(access_token)
                if api_key.present? && api_key.user == user
                    respond_to do |format|
                        format.xml {
                            render xml: user,
                                   :status => :ok,
                                   except: [:created_at, :updated_at, :password_digest, :remember_token, :elephant_admin, :create_password, :unverified_network, :verified_networks, :network_access_code, :accepted_tou]
                        }
                    end

                    return

                else
                    message = 'Invalid access token'
                end

            else
                message = 'Invalid user id'
            end

        else
            message = 'Please fill all information'
        end

        respond_to do |format|
            format.xml {
                render xml: {:message => message},
                       :status => :unauthorized
            }
        end
    end

    def register_job

        message = ''
        puts "Register Job"
        if params[:user_id] && params[:access_token] && params[:well_name] && params[:rig_name]
            user = User.find(params[:user_id])

            if user.present?
                access_token = params[:access_token]

                api_key = ApiKey.find_by_access_token(access_token)
                if api_key.present? && api_key.user == user

                    puts "User Authenticated"
                    Job.transaction do
                        @rig = Rig.where(:company_id => user.company.id).where("rigs.name = ?", params[:rig_name]).limit(1).first
                        if !@rig.present?
                            puts "Rig Not Present"
                            @rig = nil
                            @rig = Rig.new
                            @rig.company = user.company
                            @rig.name = params[:rig_name]

                            if !@rig.save
                                message = "Rig Error!"
                                respond_to do |format|
                                    format.xml {
                                        render xml: {:message => message},
                                               :status => :unauthorized
                                    }
                                end
                                raise ActiveRecord::Rollback
                                return
                            end
                        else
                            puts "Rig Present"
                        end

                        @well = Well.where(:company_id => user.company.id).where("wells.name = ?", params[:well_name]).limit(1).first
                        @job = nil
                        if !@well.present?
                            puts "Well Not Present"
                            @well = nil
                            @well = Well.new
                            @well.field = user.company.fields.first
                            @well.name = params[:well_name]
                            @well.company = user.company
                            @well.programs = [@rig.program] if !@rig.program.nil?
                            @well.rig = @rig
                            if @rig.offset_well.present?
                                @well.offset_well = @rig.offset_well
                            end
                            if @well.programs.empty?
                                if @rig.program.present?
                                    @well.programs << @rig.program
                                end
                            end

                            if !@well.save
                                puts params[:well_name]
                                puts @well.errors.full_messages
                                respond_to do |format|
                                    format.xml {
                                        render xml: {:message => message},
                                               :status => :unauthorized
                                    }
                                end
                                raise ActiveRecord::Rollback
                                return
                            end
                            @job = Job.new
                            @job.district = user.district
                            @job.company = user.company
                            @job.well = @well
                            @job.field = user.company.fields.first
                        else
                            puts "Well Present"
                            @job = @well.jobs.first
                            @job.clean_job
                        end


                        @job.status = Job::ON_JOB
                        @job.time_step = params[:time_step].to_i

                        puts "Job Try Save"
                        if @job.save

                            puts "Job Saved"
                            message = "Job created!"

                        else
                            puts @job.errors.full_messages
                            message = "Job Error!"
                            respond_to do |format|
                                format.xml {
                                    render xml: {:message => message},
                                           :status => :unauthorized
                                }
                            end
                            raise ActiveRecord::Rollback
                            return
                        end

                        if @job.id.present?

                            puts "Job ID #{@job.id.to_s}"

                            table_name = "wits_records#{@job.id}"
                            if !(WitsRecord.connection.table_exists? table_name)
                                WitsRecord.connection.execute("CREATE TABLE #{table_name} (LIKE wits_records INCLUDING DEFAULTS INCLUDING INDEXES)")
                            end
                            message = "Job created!"
                            respond_to do |format|
                                format.xml {
                                    render xml: @job,
                                           :status => :ok,
                                           except: [:created_at, :updated_at, :rating, :job_members, :job_number, :inventory_notes, :inventory_confirmed, :api_number, :total_cost, :proposed_cost, :shared, :drilling_company_id, :directional_drilling_company_id, :fluids_company_id, :perfect_well_ratio]
                                }
                            end
                            return
                        end
                    end
                    return

                else
                    message = 'Invalid access token'
                end

            else
                message = 'Invalid user id'
            end

        else
            message = 'Please fill all information'
        end

        respond_to do |format|
            format.xml {
                render xml: {:message => message},
                       :status => :unauthorized
            }
        end
    end

    def new_record
        puts "New Configuration Record"
        puts "............"

        json = JSON.parse(request.body.read)
        puts json

        user_id = json["UserId"]
        access_token = json["ApiKey"]


        if user_id && access_token
            user = User.find(user_id)
            if user.present?
                api_key = ApiKey.find_by_access_token(access_token)
                if api_key.present? && api_key.user == user
                    if json && json["TemplateName"] != nil
                        @record = ConfigurationRecord.new(json, user)
                        if @record.job
                            if @record.drill_strings.any? || @record.bit
                                @record.job.add_drill_string_configuration_record(@record)
                            end
                            if @record.fluid != nil
                                @record.job.add_fluid_configuration_record(@record)
                            end
                            if @record.surveys != nil
                                @record.job.add_surveys(@record)
                            end
                        end
                        puts @record.date
                    end
                end

            end

        end
        render :nothing => true, :status => :ok
    end
end