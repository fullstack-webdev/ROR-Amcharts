class PerformanceController1 < ApplicationController
    before_filter :signed_in_user, only: [:index]

    set_tab :performance

    def index
        @ret = []
        @wells = []
        # @programs = Program.includes(wells: {jobs: :wits_category_allocs}).group()
        # sql = "select "
        # @programs = ActiveRecord::Base.connection.execute(sql)

        @new_programs = []
        @color_palette = ["#58c9c2", "#b858c9", "#589dc9", "#9babee", "#23c9ff", "#9aea6a", "#9eddde", "#987cf4", "#23fcff"]

        if params[:section] == "rigs" || params[:section] == "rigs_well_time" || params[:section] == "rigs_cost" || params[:section] == "rigs_warnings" || params[:section] == "rigs_process_time" || params[:section] == "rigs_histogram_data"
            jobs = current_user.company.jobs
            rig_ids = []
            jobs.each do |job|
                if job.well.rig != nil
                    rig_ids << job.well.rig.id
                end
            end
            # @wits_category_list = WitsCategoryList.where("job_id IN (?) and category_name = ?", jobs, iterator).order("operation_time asc")
            @rigs = Rig.includes(:wells).where("id IN (?)", rig_ids)
            puts @rigs.to_json
        elsif params[:section] == "crew_rigs" || params[:section] == "crew_rigs_well_time" || params[:section] == "crew_rigs_cost" || params[:section] == "crew_rigs_warnings" || params[:section] == "crew_rigs_process_time" || params[:section] == "crew_rigs_histogram_data"
            jobs = current_user.company.jobs
            rig_ids = []
            jobs.each do |job|
                rig_ids << job.well.rig.id
            end
            # @wits_category_list = WitsCategoryList.where("job_id IN (?) and category_name = ?", jobs, iterator).order("operation_time asc")
            @crew_rigs = Rig.includes(:wells).where("id IN (?)", rig_ids)
        elsif  params[:section] == "counties" || params[:section] == "counties_well_time" || params[:section] == "counties_cost" || params[:section] == "counties_warnings" || params[:section] == "counties_process_time" || params[:section] == "counties_histogram_data"
            @counties = [];
        elsif  params[:section] == "contractors" || params[:section] == "contractors_well_time" || params[:section] == "contractors_cost" || params[:section] == "contractors_warnings" || params[:section] == "contractors_process_time" || params[:section] == "contractors_histogram_data"
            @contractors = [];
        elsif  params[:section] == "wells" || params[:section] == "wells_well_time" || params[:section] == "wells_cost" || params[:section] == "wells_warnings" || params[:section] == "wells_process_time" || params[:section] == "wells_histogram_data"
            jobs = current_user.company.jobs
            @wells = []
            jobs.each do |job|
                @wells << job.well
            end
            @wells = @wells.uniq
        else
            @programs = Program.includes(:wells).select { |program| program.wells.count > 0 }
        end


        respond_to do |format|
            format.html {
            }
            format.js {
            }
            format.json do
                case params['section']
                    when "programs_histogram_data"
                        if (!params['program_id'].nil?)
                            if params['program_id'].to_i == -1
                                render json: programs_wits_category_histogram(@programs, params['history'].to_i)
                            else
                                program = Program.find(params['program_id'])
                                render json: program.program_wits_category_histogram(params['history'].to_i)
                            end
                            return
                        end
                    when "rigs_histogram_data"
                        if (!params['rig_id'].nil?)
                            if params['rig_id'].to_i == -1
                                render json: rigs_wits_category_histogram(@rigs, params['history'].to_i)
                            else
                                rig = Rig.find(params['rig_id'])
                                render json: rig.rig_wits_category_histogram(params['history'].to_i)
                            end
                            return
                        end
                    when "wells_histogram_data"
                        if (!params['well_id'].nil?)
                            if params['well_id'].to_i == -1
                                render json: wells_wits_category_histogram(@wells, params['history'].to_i)
                            else
                                well = Well.find(params['well_id'])
                                render json: well.wits_category_histogram(params['history'].to_i)
                            end
                            return
                        end
                    when "crew_rigs_histogram_data"
                        if (!params['crew_rig_id'].nil?)
                            if params['crew_rig_id'].to_i == -1
                                render json: crew_rigs_wits_category_histogram(@crew_rigs, params['history'].to_i)
                            else
                                id_arr = params['crew_rig_id'].split("-")
                                rig = Rig.find(id_arr[0])
                                render json: rig.crew_rig_wits_category_histogram(id_arr[1], params['history'].to_i)
                            end
                            return
                        end
                end

            end
        end

    end

    # def rigs_wits_category_histogram(rigs, history=-1)
    #   @wits_category_histogram = Hash.new
    #   benchmark_arr = Array.new
    #   benchmark_arr.push(40, 30, 40, 20, 80, 350, 230, 1400)
    #
    #   min_date = nil
    #   if history.to_i > 0
    #     min_date = DateTime.now - history.to_i.months
    #   end
    #   jobs = []
    #   rigs.each_with_index do |rig, index|
    #     if history.to_i > 0
    #       jobs = jobs + rig.jobs.where('start_date >= ?', min_date).collect {|e| e['id']}
    #     else
    #       jobs = jobs + rig.jobs.collect {|e| e['id']}
    #     end
    #
    #   end
    #
    #   jobs = jobs.uniq
    #   total_rigs_time = 0.0
    #   jobs.each do |job|
    #     total_rigs_time = total_rigs_time + Job.find(job).total_job_time
    #   end
    #   for iterator in 0..7
    #
    #     @wits_category_list = WitsCategoryList.where("job_id IN (?) and category_name = ?", jobs, iterator).order("operation_time asc")
    #     if @wits_category_list.present?
    #       total_time = @wits_category_list.sum(:operation_time)
    #       total_count = @wits_category_list.count
    #       average_time = (total_time.to_f / total_count.to_f).round(2)
    #       time_break = 15
    #
    #       max_operation_time = @wits_category_list.maximum(:operation_time).to_i
    #
    #       tmp_histo_data_arr = Array.new(max_operation_time / time_break + 1) {|e| e = 0}
    #
    #       @wits_category_list.each do |category|
    #         tmp_histo_data_arr[category.operation_time / time_break] += 1
    #       end
    #       histo_data_arr = Array.new
    #       for index in 0..((average_time.to_i / time_break).to_i + 1)
    #         histo_data_arr[index] = Hash["op_time"=>(index + 1) * 0.25, "op_count"=>tmp_histo_data_arr[index]]
    #       end
    #
    #       ten_percent = @wits_category_list.limit(total_count.to_i / 10).collect(&:operation_time).max
    #       fifty_percent = @wits_category_list.limit(total_count.to_i * 5 / 10).collect(&:operation_time).max
    #       ninety_percent = @wits_category_list.limit(total_count.to_i * 9 / 10).collect(&:operation_time).max
    #
    #       savings = [(total_time - total_count * benchmark_arr[iterator.to_i]), 0].max.to_f / 60.0 / 60.0 / 24.0
    #       puts "=========total========"
    #       puts total_rigs_time.to_f
    #       puts total_time / 60.0 / 60.0 / 24.0
    #       puts total_count * benchmark_arr[iterator.to_i] / 60.0 / 60.0 / 24.0
    #       puts savings
    #       potential_saving = savings * 100 / total_rigs_time.to_f
    #       puts potential_saving
    #
    #       @wits_category_histogram[iterator] = Hash["data" => histo_data_arr, "ten_per" => ten_percent, "fifty_per" => fifty_percent.to_i, "ninety_per" => ninety_percent, "op_count" => total_count, "total_time" => (total_time / 60.0).round(2), "avg_time" => (average_time / 60.0).round(2), "max_op_time" => (max_operation_time / 60.0).round(2), "potential_saving" => potential_saving.round(2), "saving" => savings.round(2), "benchmark" => (Rig::BENCHMARK_TRIPPING_OUT_PIPE.to_f / 60).round(2)]
    #     else
    #       @wits_category_histogram[iterator] = Hash["data" => [{}], "ten_per" => 0, "fifty_per" => 0, "ninety_per" => 0, "op_count" => 0, "total_time" => 0, "avg_time" => 0, "max_op_time" => 0, "potential_saving" => 0]
    #     end
    #
    #   end
    #   # puts @wits_category_histogram
    #   return @wits_category_histogram
    # end

    # def programs_wits_category_histogram(programs, history=-1)
    #   @wits_category_histogram = Hash.new
    #   benchmark_arr = Array.new
    #   benchmark_arr.push(40, 30, 40, 20, 80, 350, 230, 1400)
    #
    #   min_date = nil
    #   if history.to_i > 0
    #     min_date = DateTime.now - history.to_i.months
    #   end
    #   jobs = []
    #   programs.each_with_index do |program, index|
    #     if history.to_i > 0
    #       jobs = jobs + program.jobs.where('start_date >= ?', min_date).collect {|e| e['id']}
    #     else
    #       jobs = jobs + program.jobs.collect {|e| e['id']}
    #     end
    #
    #   end
    #
    #   jobs = jobs.uniq
    #   total_programs_time = 0.0
    #   jobs.each do |job|
    #     total_programs_time = total_programs_time + Job.find(job).total_job_time
    #   end
    #   for iterator in 0..7
    #
    #     @wits_category_list = WitsCategoryList.where("job_id IN (?) and category_name = ?", jobs, iterator).order("operation_time asc")
    #     if @wits_category_list.present?
    #       total_time = @wits_category_list.sum(:operation_time)
    #       total_count = @wits_category_list.count
    #       average_time = (total_time.to_f / total_count.to_f).round(2)
    #       time_break = 15
    #
    #       max_operation_time = @wits_category_list.maximum(:operation_time).to_i
    #
    #       tmp_histo_data_arr = Array.new(max_operation_time / time_break + 1) {|e| e = 0}
    #
    #       @wits_category_list.each do |category|
    #         tmp_histo_data_arr[category.operation_time / time_break] += 1
    #       end
    #       histo_data_arr = Array.new
    #       for index in 0..((average_time.to_i / time_break).to_i + 1)
    #         histo_data_arr[index] = Hash["op_time"=>(index + 1) * 0.25, "op_count"=>tmp_histo_data_arr[index]]
    #       end
    #
    #       ten_percent = @wits_category_list.limit(total_count.to_i / 10).collect(&:operation_time).max
    #       fifty_percent = @wits_category_list.limit(total_count.to_i * 5 / 10).collect(&:operation_time).max
    #       ninety_percent = @wits_category_list.limit(total_count.to_i * 9 / 10).collect(&:operation_time).max
    #
    #       savings = [(total_time - total_count * benchmark_arr[iterator.to_i]), 0].max.to_f / 60.0 / 60.0 / 24.0
    #       puts "=========total========"
    #       puts total_programs_time.to_f
    #       puts total_time / 60.0 / 60.0 / 24.0
    #       puts total_count * benchmark_arr[iterator.to_i] / 60.0 / 60.0 / 24.0
    #       puts savings
    #       potential_saving = savings * 100 / total_programs_time.to_f
    #       puts potential_saving
    #
    #       @wits_category_histogram[iterator] = Hash["data" => histo_data_arr, "ten_per" => ten_percent, "fifty_per" => fifty_percent.to_i, "ninety_per" => ninety_percent, "op_count" => total_count, "total_time" => (total_time / 60.0).round(2), "avg_time" => (average_time / 60.0).round(2), "max_op_time" => (max_operation_time / 60.0).round(2), "potential_saving" => potential_saving.round(2), "saving" => savings.round(2), "benchmark" => (Rig::BENCHMARK_TRIPPING_OUT_PIPE.to_f / 60).round(2)]
    #     else
    #       @wits_category_histogram[iterator] = Hash["data" => [{}], "ten_per" => 0, "fifty_per" => 0, "ninety_per" => 0, "op_count" => 0, "total_time" => 0, "avg_time" => 0, "max_op_time" => 0, "potential_saving" => 0]
    #     end
    #
    #   end
    #   # puts @wits_category_histogram
    #   return @wits_category_histogram
    # end
    def wells_wits_category_histogram(wells, history=-1)
        @wits_category_histogram = Hash.new
        wells.each do |well|
            @wits_category_histogram[well.id] = well.well_wits_category_histogram(history)
        end
        return @wits_category_histogram
    end

    def programs_wits_category_histogram(programs, history=-1)
        @wits_category_histogram = Hash.new
        programs.each do |program|
            @wits_category_histogram[program.id] = program.program_wits_category_histogram(history)
        end
        return @wits_category_histogram
    end

    def rigs_wits_category_histogram(rigs, history=-1)
        @wits_category_histogram = Hash.new
        rigs.each do |rig|
            @wits_category_histogram[rig.id] = rig.rig_wits_category_histogram(history)
        end
        return @wits_category_histogram
    end

    def crew_rigs_wits_category_histogram(rigs, history=-1)
        @wits_category_histogram = Hash.new
        rigs.each do |rig|
            @wits_category_histogram[rig.id.to_s + "-0"] = rig.crew_rig_wits_category_histogram(0, history)
            @wits_category_histogram[rig.id.to_s + "-1"] = rig.crew_rig_wits_category_histogram(1, history)
        end
        return @wits_category_histogram
    end
end
