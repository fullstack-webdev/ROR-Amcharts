class RigsController < ApplicationController
    before_filter :signed_in_user, only: [:index]
    before_filter :signed_in_user_not_field, only: [:new, :show, :create, ]

    def index
        respond_to do |format|
            format.html { @rigs = current_user.company.rigs.all }
            format.js {
                @query = params[:search]
                @rigs = Rig.search(params, current_user.company).results
            }
            format.json {
                if params[:q].present?
                    params[:search] = params[:q]
                end

                @rigs = Rig.search(params, current_user.company)

                # puts "=====rigs====="
                # puts @rigs.to_json
                if @rigs.empty?
                    @rigs << Rig.new
                    render json: @rigs.map { |rig| {:value => "No rig found...", :name => "", :id => -1} }
                    return
                end

                if params[:q].present?
                    render json: @rigs.map { |rig| {:name => rig.name, :id => rig.id} }
                else
                    render json: @rigs.map { |rig| {:label => rig.name, :id => rig.id} }
                end
            }
        end

    end


    def show
        @rig = Rig.find(params[:id])
        jobs = @rig.jobs
        @jobs_array = jobs.includes(:job_memberships).includes(well: :rig).to_a
        @jobs_array = @jobs_array.uniq { |j| "#{j.well.rig.name} - #{j.well.name}" }.sort_by { |j| "#{j.start_date} " }.reverse

        offset_jobs = current_user.company.jobs
        @offset_jobs_array = offset_jobs.includes(:job_memberships).includes(well: :rig).to_a
        @offset_jobs_array = @offset_jobs_array.uniq { |j| "#{j.well.rig.name} - #{j.well.name}" }.sort_by { |j| "#{j.start_date} " }.reverse
        @programs = Program.all
        not_found unless @rig.present?
    end

    def new
        @rig = Rig.new
        jobs = @rig.jobs
        @jobs_array = jobs.includes(:job_memberships).includes(well: :rig).to_a
        @jobs_array = @jobs_array.uniq { |j| "#{j.well.rig.name} - #{j.well.name}" }.sort_by { |j| "#{j.start_date} " }.reverse

        offset_jobs = current_user.company.jobs
        @offset_jobs_array = offset_jobs.includes(:job_memberships).includes(well: :rig).to_a
        @offset_jobs_array = @offset_jobs_array.uniq { |j| "#{j.well.rig.name} - #{j.well.name}" }.sort_by { |j| "#{j.start_date} " }.reverse
        @programs = Program.all
    end

    def edit
        @rig = Rig.find(params[:id])
    end

    def create
        params[:rig][:block_weight] = (params[:rig][:block_weight].gsub(',', '').to_f || 0).convert_default(:klbf, company_unit)
        @rig = Rig.new(params[:rig])
        @rig.company = current_user.company

        respond_to do |format|
          if @rig.save
            format.html { redirect_to @rig, notice: 'Rig was successfully updated.' }
            format.json { head :no_content }
          else
            format.html { render action: "edit" }
            format.json { render json: @rig.errors, status: :unprocessable_entity }
          end
        end
    end

    def update
      puts "====update_rig"
      puts params
      @rig = Rig.find_by_id(params[:id])

      not_found unless @rig.present? && @rig.company == current_user.company

      if params[:update_field].present? && params[:update_field] == "true" &&
          params[:field].present? && params[:value].present?
        case params[:field]
          when "offset_well_id"
            @rig.update_attribute(:offset_well_id, params[:value])
            wells = @rig.wells.where("id != ? and offset_well_id is null", params[:value])
            # puts wells.as_json
            wells.each do |well|
              well.update_attribute(:offset_well_id, params[:value])
            end
          when "drilling_program_id"
            # puts "====drilling_program"
            # puts @rig
            @rig.update_attribute(:program_id, params[:value])
            wells = @rig.wells.find(:all, :include => :programs, :conditions => { "programs_wells.program_id" => nil})

            # puts wells.as_json

            wells.each do |well|
              well.programs.clear
              well.programs << Program.find_all_by_id([params[:value]])
              well.save
            end
        end
      else
        respond_to do |format|
            params[:rig][:block_weight] = (params[:rig][:block_weight].gsub(',', '').to_f || 0).convert_default(:klbf, company_unit)
            puts "Block Weight"
            puts params[:rig][:block_weight]
            if @rig.update_attributes(params[:rig])
                format.html { redirect_to @rig, notice: 'Rig was successfully updated.' }
                format.json { head :no_content }
              else
                format.html { render action: "edit" }
                format.json { render json: @rig.errors, status: :unprocessable_entity }
              end
        end
      end

    end

end
