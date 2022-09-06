class BhasController < ApplicationController
    before_filter :signed_in_user, only: [:show, :new, :create, :edit, :update, :destroy]

    def show
        if params[:bhas].present? && params[:bhas] == "true"
            @bha = Bha.find_by_id(params[:id])
            not_found unless @bha.present? && @bha.company == current_user.company

            @bhas = Bha.includes(job: :well).where("wells.id = ?", @bha.job.well_id).order("bhas.created_at ASC")
        else
            @job = Job.find_by_id(params[:id])
            not_found unless !@job.nil? && @job.company == current_user.company

            @bhas = Bha.includes(job: :well).where("wells.id = ?", @job.well_id).order("bhas.created_at ASC")

            if params[:bha].present?
                @bha = Bha.find_by_id(params[:bha])
                not_found unless @bha.company == current_user.company
            else
                @bha = @bhas.first
            end
        end
    end

    def new
        if params[:clone].present? && params[:clone] == "true"
            old_bha = Bha.find_by_id(params[:bha])
            not_found unless old_bha.company == current_user.company
            Bha.transaction do
                @bha = Bha.new
                @bhas = Bha.includes(job: :well).where("bhas.master_bha_id IS NULL").where("wells.id = ?", old_bha.job.well_id).order("bhas.name ASC")
                @bha.name = (@bhas.last.name.to_i + 1).to_s
                @bha.company = current_user.company
                @bha.job = old_bha.job
                @bha.save

                old_bha.bha_items.each do |item|
                    new_item = BhaItem.new
                    new_item.bha = @bha
                    new_item.company = current_user.company
                    new_item.asset_type = item.asset_type
                    new_item.inner_diameter = item.inner_diameter
                    new_item.outer_diameter = item.outer_diameter
                    new_item.length = item.length
                    new_item.ordering = item.ordering
                    new_item.up = item.up
                    new_item.down = item.down
                    new_item.save
                end

                redirect_to edit_bha_path(@bha)
            end
        else
            @bha = Bha.new
            @job = Job.find_by_id(params[:job])

            if params[:bha].present?
                @master_bha = Bha.find(params[:bha])
            end
        end
    end

    def create
        job_id = params[:bha][:job_id]
        params[:bha].delete(:job_id)

        master_bha_id = params[:bha][:master_bha_id]
        params[:bha].delete(:master_bha_id)

        @job = Job.find_by_id(job_id)
        @bha = Bha.new(params[:bha])
        @bha.company = current_user.company
        @bha.job = @job
        if !master_bha_id.blank?
            @master_bha = Bha.find_by_id(master_bha_id)
            @bha.master_bha = @master_bha
            @bha.name = @bha.master_bha.name + ' - Tool String'
        end

        Bha.transaction do
            if @bha.save
                index = 0
                if params[:bha_items].present?
                    params[:bha_items].each do |k, v|
                        if v == "1"

                            id = BigDecimal.new(params[k + '_id'])
                            od = BigDecimal.new(params[k + '_od'])
                            length = BigDecimal.new(params[k + '_length'])
                            up = params[k + '_up']
                            asset_type = params[k + '_asset_type']
                            down = params[k + '_down']

                            BhaItem.add(@bha, id, od, length, up, down, asset_type, index)
                            index = index + 1
                        end
                    end
                end

                @bha.delay.create_activity(current_user, Activity::CREATE_BHA)

                redirect_to job_path(@job, anchor: "bha", bha: @bha.master_bha.present? ? @bha.master_bha : @bha)
            else
                render 'new'
            end
        end
    end

    def edit
        @bha = Bha.find_by_id(params[:id])
        @job = @bha.job

        @master_bha = @bha.master_bha
    end


    def update
        @bha = Bha.find_by_id(params[:id])
        not_found unless @bha.company == current_user.company

        @job = @bha.job

        Bha.transaction do
            if params[:bha].present? && params[:bha][:name].present?
                passed = @bha.update_attribute(:name, params[:bha][:name])
            else
                passed = true
            end
            if passed
                if params[:bha].present? && params[:bha][:name].present?
                    @bha.update_attribute(:description, params[:bha][:description])
                    @bha.update_attribute(:bit_to_sensor, params[:bha][:bit_to_sensor])
                    @bha.update_attribute(:bit_to_gamma, params[:bha][:bit_to_gamma])
                end

                @bha.bha_items.each do |i|
                    i.destroy
                end

                index = 0
                if params[:bha_items].present? && params[:bha_items].any?
                    params[:bha_items].each do |k, v|
                        if v == "1"


                            id = BigDecimal.new(params[k + '_id'])
                            od = BigDecimal.new(params[k + '_od'])
                            length = BigDecimal.new(params[k + '_length'])
                            up = params[k + '_up']
                            asset_type = params[k + '_asset_type']
                            down = params[k + '_down']

                            BhaItem.add(@bha, id, od, length, up, down, asset_type, index)
                            index = index + 1
                        end
                    end
                end

                @bha.delay.update_usage
                @bha.delay.create_activity(current_user, Activity::UPDATE_BHA)


                redirect_to job_path(@job, anchor: "bha", bha: @bha.master_bha.present? ? @bha.master_bha : @bha)
            else
                render 'edit'
            end
        end
    end


    def destroy
        @bha = Bha.find_by_id(params[:id])
        @original_bha = @bha
        @job = @bha.job
        not_found unless @bha.company == current_user.company

        if DrillingLogEntry.where(:bha_id => @bha.id).count == 0
            @bha.destroy

            @bhas = Bha.where(:job_id => @job.id).order("bhas.created_at ASC")
            @bha = @bhas.first
        else
            flash[:error] = "This BHA is attached to log entries and therefore can't be deleted. Delete the log if you really want to continue."
        end

        @original_bha.create_activity(current_user, Activity::DELETE_BHA)

        redirect_to job_path(@job, anchor: "bha", bha: @bha.present? && @bha.master_bha.present? ? @bha.master_bha : @bha)
    end

end