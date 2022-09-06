class DynamicFieldsController < ApplicationController
    before_filter :signed_in_admin, only: [:new, :create, :destroy]
    before_filter :signed_in_user, only: [:index, :show, :update]

    respond_to :js
    include JobsHelper

    def index
        @job = Job.find_by_id(params[:job])
        not_found unless @job.company == current_user.company

        respond_to do |format|
            format.html {
                not_found
            }
            format.xlsx {
                excel = custom_data_to_excel @job
                send_data excel.to_stream.read, :filename => "#{@job.field.name} | #{@job.well.name} - Job Data.xlsx", :type => "application/vnd.openxmlformates-officedocument.spreadsheetml.sheet"
            }
        end
    end

    def show
        @dynamic_field = DynamicField.find(params[:id])
        not_found unless @dynamic_field.present? && @dynamic_field.company == current_user.company

        respond_to do |format|
            format.js {
                if params[:reorder].present?
                    if params[:reorder] == "-1"
                        if @dynamic_field.ordering > 0
                            DynamicField.transaction do
                                @dynamic_field.ordering -= 1
                                @dynamic_field.save

                                collection = @dynamic_field.job_template.dynamic_fields
                                collection.each do |field|
                                    if field != @dynamic_field and (field.ordering || 0) == @dynamic_field.ordering
                                        field.ordering = (field.ordering || 0) + 1
                                        field.save
                                    end
                                end
                            end

                            @move_up = true

                            render 'dynamic_fields/reorder'
                        else
                            render :nothing => true, :status => :ok
                        end
                    end
                end
            }
        end
    end

    def new
        @dynamic_field = DynamicField.new(params[:dynamic_field])
    end

    def create

        job_template_id = params[:dynamic_field][:job_template_id]
        params[:dynamic_field].delete(:job_template_id)

        value = params[:dynamic_field][:value]
        params[:dynamic_field].delete(:value)

        @dynamic_field = DynamicField.new(params[:dynamic_field])
        @dynamic_field.company = current_user.company
        @dynamic_field.job_template = JobTemplate.find_by_id(job_template_id)
        @dynamic_field.ordering = @dynamic_field.job_template.dynamic_fields.count

        if !value.blank?
            if @dynamic_field.value_type != DynamicField::VALUES
                @dynamic_field.predefined = true
                @dynamic_field.value = value
            else
                @dynamic_field.values = value
            end
        else
            @dynamic_field.predefined = false
        end

        if !@dynamic_field.save
            render 'error'
        end

        Activity.add(self.current_user, Activity::DYNAMIC_FIELD_CREATED, @dynamic_field, @dynamic_field.name)

    end

    def edit
        @dynamic_field = DynamicField.find(params[:id])
        not_found unless @dynamic_field.company == current_user.company
    end

    def update

        if params[:id] == "0"
            if params[:job].present?
                job = Job.find_by_id(params[:job])
                if params[:name] == "Job Number"
                    job.update_attribute(:job_number, params[:value])
                elsif params[:name] == "API Number"
                    job.update_attribute(:api_number, params[:value])
                end
                render :nothing => true, :status => 200
                return
            end
        end

        @dynamic_field = DynamicField.find(params[:id])

        @is_valid = true

        if @dynamic_field.template?
            DynamicField.transaction do
                @dynamic_field.update_attribute(:name, params[:dynamic_field][:name])
                @dynamic_field.update_attribute(:value_type, params[:dynamic_field][:value_type])
                @dynamic_field.update_attribute(:priority, params[:dynamic_field][:priority])
                @dynamic_field.update_attribute(:optional, params[:dynamic_field][:optional])
                if !params[:dynamic_field][:value].blank?
                    if @dynamic_field.value_type != DynamicField::VALUES
                        @dynamic_field.update_attribute(:predefined, true)
                        @dynamic_field.update_attribute(:value, params[:dynamic_field][:value])
                    else
                        @dynamic_field.update_attribute(:values, params[:dynamic_field][:value])
                    end
                else
                    @dynamic_field.update_attribute(:predefined, false)
                end
            end
        else
            if params[:value].present?
                @save_value = params[:value]
                if @dynamic_field.value_type != DynamicField::STRING
                    @save_value.gsub!(',', '')
                    @is_valid = @save_value.match(/\A[+-]?\d+?(\.\d+)?\Z/) != nil
                end
                @dynamic_field.value = @save_value
                @dynamic_field.save
            elsif params[:unit].present?
                @dynamic_field.value_type = params[:unit]
                @dynamic_field.save
            end

            begin
                activity = @dynamic_field.job.activity.limit(1).last
                if activity != nil and (activity.created_at > 10.minutes.ago) and activity.activity_type == Activity::DATA_EDITED && activity.metadata.length < 200
                    activity.metadata += ", " + @dynamic_field.name + " - " + @dynamic_field.value + " " + @dynamic_field.get_value_type_unit(@dynamic_field.value_type)
                    activity.save
                elsif params[:value].present?
                    Activity.add(current_user, Activity::DATA_EDITED, @dynamic_field, @dynamic_field.name + " - " + @dynamic_field.value + " " + " " + @dynamic_field.get_value_type_unit(@dynamic_field.value_type), @dynamic_field.job)
                end
            rescue
            end
        end
    end

    def destroy
        @dynamic_field = DynamicField.find(params[:id])
        not_found unless @dynamic_field.company == current_user.company
        @dynamic_field.destroy

        if !@dynamic_field.destroy
            render 'error'
        end

        Activity.add(self.current_user, Activity::DYNAMIC_FIELD_DESTROYED, @dynamic_field, @dynamic_field.name)

    end

end
