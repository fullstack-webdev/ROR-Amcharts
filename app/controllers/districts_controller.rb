class DistrictsController < ApplicationController
    before_filter :signed_in_user, only: [:index, :show]
    before_filter :signed_in_admin, only: [:new, :edit, :create, :edit, :update, :destroy]
    set_tab :districts

    def index
        respond_to do |format|
            format.html { @districts = District.from_company(current_user.company).where(:master => true).paginate(page: params[:page], limit: 20) }
            format.js {
                @query = params[:search]
                master = params[:master].present? ? params[:master] == "true" : true
                @districts = District.search(params, current_user.company, master).results
            }
            format.json {
                if params[:q].present?
                    params[:search] = params[:q]
                end

                master = params[:master].present? ? params[:master] == "true" : false
                @districts = District.search(params, current_user.company, master).results

                if @districts.empty?
                    @districts << District.new
                    render json: @districts.map { |district| {:value => "No district found...", :name => "", :id => -1, :country => ""} }
                    return
                end

                if params[:q].present?
                    render json: @districts.map { |district| {:name => district.name + " (" + district.region + " / " + district.country + " / " + district.state + " " + district.city + ")", :id => district.id} }
                else
                    render json: @districts.map { |district| {:label => district.name,
                                                              :region => district.region.present? ? district.region : "",
                                                              :country => district.country.present? ? district.country.name : "",
                                                              :state => district.state.present? ? district.state.name : "",
                                                              :city => district.city.present? ? district.city : "",
                                                              :id => district.id} }
                end
            }
        end
    end

    def show

        @district = District.find_by_id(params[:id])
        not_found unless @district.present? && @district.company == current_user.company

        if params[:search] && !params[:search].blank?
            @jobs = District.from_company_for_user(@district, params, current_user, current_user.company).results
        else
            @district_jobs = UserRole.limit_jobs_scope current_user, @district.jobs
            @jobs = @district_jobs.includes(dynamic_fields: :dynamic_field_template).includes(:field, :well, :documents, :district).paginate(page: params[:page], limit: 20)
        end
    end

    def new
        @district = District.new
        @company = current_user.company

        @countries = Country.all
        @states = State.all

        @master_district_id = params[:master_district]
        @master = params[:master] == "true"

        if !params[:master_district].blank?
            @master_district = District.find_by_id(params[:master_district])
            not_found unless @master_district.company == current_user.company
            @country = @master_district.country.id
            if !@country.blank?
                @states = @master_district.country.states
            end
            if @master_district.state.present?
                @state = @master_district.state.id
            end
        end
    end

    def create
        country_id = params[:district][:country_id]
        params[:district].delete(:country_id)

        state_id = params[:district][:state_id]
        params[:district].delete(:state_id)

        master_district_id = params[:district][:master_district_id]
        params[:district].delete(:master_district_id)


        @district = District.new(params[:district])
        @district.company = current_user.company
        @district.country = Country.find_by_id(country_id)
        if state_id.present?
            @district.state = State.find_by_id(state_id)
        end
        if !master_district_id.blank?
            @master_district_id = master_district_id
            @district.master_district = District.find_by_id(master_district_id)
            not_found unless @district.master_district.company == current_user.company
            @district.master = false

            @country = @district.master_district.country.id
            if @district.master_district.state.present?
                @state = @district.master_district.state.id
            end
        else
            @district.master = true
        end

        @master = @district.master

        if !@district.master? && District.where("lower(districts.name) = lower(:district_name) AND districts.master = FALSE AND districts.company_id = :company_id", district_name: @district.name, company_id: current_user.company.id).any?
            @district.errors.add(:name, "has already been taken")
            saved = false
        elsif @district.master? && District.where("lower(districts.name) = lower(:district_name) AND districts.master = TRUE AND districts.company_id = :company_id", district_name: @district.name, company_id: current_user.company.id).any?
            @district.errors.add(:name, "has already been taken")
            saved = false
        else
            saved = @district.save
        end

        respond_to do |format|
            format.html {
                if saved

                    Activity.add(self.current_user, Activity::DISTRICT_CREATED, @district, @district.name)

                    flash[:success] = "District created - #{@district.name}"

                    if @district.master?
                        redirect_to edit_district_path(@district)
                    else
                        redirect_to edit_district_path(@district.master_district)
                    end
                else
                    @countries = Country.all
                    @states = State.all
                    render 'new'
                end
            }
            format.js
        end
    end

    def edit
        @district = District.find_by_id(params[:id])
        not_found unless @district.company == current_user.company
        @company = current_user.company

        @countries = Country.all

        if @district.country.nil?
            @states = State.all
        else
            @states = @district.country.states
        end

        @country = @district.country.id
        if @district.state.present?
            @state = @district.state.id
        end

        if @district.master?
            if params[:edit] == "true"
                @master = params[:master] == "true"
            else
                render "districts/edit_master"
                return
            end
        end
    end

    def update

        @district = District.find_by_id(params[:id])
        not_found unless @district.company == current_user.company

        if @district.update_attribute(:name, params[:district][:name])
            @district.update_attribute(:country_id, params[:district][:country_id])
            @district.update_attribute(:state_id, params[:district][:state_id])
            @district.update_attribute(:time_zone, params[:district][:time_zone])
            @district.update_attribute(:region, params[:district][:region])
            @district.update_attribute(:address_line_1, params[:district][:address_line_1])
            @district.update_attribute(:address_line_2, params[:district][:address_line_2])
            @district.update_attribute(:city, params[:district][:city])
            @district.update_attribute(:postal_code, params[:district][:postal_code])
            @district.update_attribute(:phone_number, params[:district][:phone_number])
            @district.update_attribute(:support_email, params[:district][:support_email])


            Activity.add(self.current_user, Activity::DISTRICT_UPDATED, @district, @district.name)

            flash[:success] = "District updated"

            if @district.master?
                redirect_to districts_path
            else
                redirect_to edit_district_path(@district.master_district)
            end
        else
            @company = current_user.company
            @countries = Country.all
            @states = State.all
            render 'edit'
        end
    end

    def destroy
        @district = District.find_by_id(params[:id])
        not_found unless @district.company == current_user.company
        @district.destroy

        Activity.add(self.current_user, Activity::DISTRICT_DESTROYED, @district, @district.name)

        flash[:success] = "District destroyed."

        if @district.master?
            redirect_to districts_path
        else
            redirect_to edit_district_path(@district.master_district)
        end
    end


end
