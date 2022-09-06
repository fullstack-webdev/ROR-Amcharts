class AdminController < ApplicationController
    before_filter :signed_in_admin, except: [:signin, :signout, :impersonate, :company_settings, :company_warnings]
    # layout 'admin'
    set_tab :admin

    def index
        company_id = params[:id]

        @companies = Company.all
        @company = @companies.first
        if company_id != nil && company_id != '' && Company.exists?(company_id)
            @company = Company.find(company_id)
        end
    end

    def signin
        if params.has_key?(:admin)
            @email = params[:admin][:email].strip.downcase
            user = User.find_by_email(@email)

            if user.nil?
                flash[:error] = "Invalid email/password combination"
                return
            end

            if user.authenticate(params[:admin][:password].strip)
                if user.elephant_admin?
                    response.headers['X-CSRF-Token'] = form_authenticity_token
                    respond_to do |format|
                        format.html {
                            if user.create_password?
                                redirect_to update_password_path(email: user.email, new_account: true), :flash => {:error => "Please create a password"}
                            else
                                sign_in(user, params[:admin]["stay_logged_in"] == "1")
                                redirect_to admin_path
                            end
                        }
                    end
                else
                    flash[:error] = "You don't have privilege to access admin dashboard."
                end
            else
                user.update_attribute(:invalid_login_attempts, user.invalid_login_attempts + 1)

                flash[:error] = "Invalid email/password combination"
            end
        end
    end

    def signout
        session[:return_to] = nil
        session[:company_id] = nil
        current_user = nil
        cookies.delete(:remember_token)

        redirect_to admin_path
    end

    def impersonate
        company_id = params[:id]

        if company_id != nil && company_id != '' && Company.exists?(company_id)
            session[:company_id] = company_id
            # set_current_tenant(Company.find(company_id))
            redirect_to root_path
        else
            not_found
        end
    end

    def company_settings
        set_tab :company

        @company = Company.find(params[:id])
        @companies = Company.all

        @possible_features = CompanyFeature.possible_features
        @all_features = CompanyFeature.all
    end

    def company_warnings
        set_tab :warnings

        @company = Company.find(params[:id])
        @companies = Company.all

        @warnings = @company.warnings_list.per_page_kaminari(params[:page]).per(EventWarning::PER_PAGE)
        @prev_time = params[:prev_time].present? ? params[:prev_time].to_time : Time.now
        @current_warnings_list = @company.current_warnings_list
    end

    private

    def elephant_admin_user
        redirect_to(root_path) unless signed_in? && current_user.elephant_admin?
    end

    def super_admin_user
        redirect_to(admin_login_path) unless signed_in_super_admin?
    end
end