class FieldsController < ApplicationController
    before_filter :signed_in_user, only: [:index, :show]
    before_filter :signed_in_user, only: [:new, :create]

    def index

        respond_to do |format|
            format.js {
                @fields = []

                if params[:district_id].present?
                    district = District.find_by_id(params[:district_id])
                    if district.company == current_user.company
                        @fields = []
                        district.master_district.districts.each do |d|
                            d.fields.each do |field|
                                @fields << field
                            end
                        end
                    end
                end
            }
            format.html {
                @fields = Field.from_company(current_user.company)
            }
        end
    end

    def show
        @field = Field.find_by_id(params[:id])
        not_found unless @field.present? && @field.company == current_user.company

        @jobs = @field.jobs current_user.company
        @jobs = UserRole.limit_jobs_scope current_user, @jobs
        @jobs = @jobs.includes(dynamic_fields: :dynamic_field_template).includes(:field, :well, :documents, :district).paginate(page: params[:page], limit: 20)
    end

    def new
        @field = Field.new
        @district = District.find_by_id(params[:district_id])

        @countries = Country.all
        @states = State.all
    end

    def create
        country_id = params[:field][:country_id]
        params[:field].delete(:country_id)

        state_id = params[:field][:state_id]
        params[:field].delete(:state_id)

        district_id = params[:field][:district_id]
        params[:field].delete(:district_id)

        @field = Field.new(params[:field])

        if country_id.present?
            @field.country = Country.find_by_id(country_id)

            if state_id.present?
                @field.state = State.find_by_id(state_id)
            end
        end

        @field.company = current_user.company
        @field.district = District.find_by_id(district_id)
        @field.save
    end


end
