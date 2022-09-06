module ApplicationHelper

    include Convertable

    def full_title(page_title)
        base_title = "Corva"
        if page_title.empty?
            base_title
        else
            "#{base_title} | #{page_title}"
        end
    end


    def link_to_add_fields(name, f, association)
        new_object = f.object.send(association).klass.new
        id = new_object.object_id
        fields = f.fields_for(association, new_object, child_index: id) do |builder|
            render(association.to_s.singularize + "_fields", f: builder)
        end
        link_to(name, '#', class: "add_fields", data: {id: id, fields: fields.gsub("\n", "")})
    end



    class MenuTabBuilder < TabsOnRails::Tabs::Builder
        def open_tabs(options = {})
            @context.tag("ul", options, open = true)
        end

        def close_tabs(options = {})
            "</ul>".html_safe
        end

        def tab_for(tab, name, options, item_options = {})
            item_options[:class] = (current_tab?(tab) ? 'current' : '')
            @context.content_tag(:li, item_options) do
                @context.link_to(name, options)
            end
        end
    end

    def my_tabs_tag(options = {})
        tabs_tag(options.merge(:builder => MenuTabBuilder))
    end

    def programs_wits_category_histogram(programs, history=-1)
      wits_category_histogram = Hash.new
      programs.each do |program|
        wits_category_histogram[program.id] = program.program_wits_category_histogram(history)
      end
      return wits_category_histogram
    end

    # def rigs_wits_category_histogram(rigs, history=-1)
    #   wits_category_histogram = Hash.new
    #   rigs.each do |rig|
    #     wits_category_histogram[rig.id] = rig.rig_wits_category_histogram(history)
    #   end
    #   return wits_category_histogram
    # end
    # def crew_rigs_wits_category_histogram(rigs, history=-1)
    #   wits_category_histogram = Hash.new
    #   rigs.each do |rig|
    #     wits_category_histogram[rig.id.to_s+"-0"] = rig.crew_rig_wits_category_histogram(0,history)
    #     wits_category_histogram[rig.id.to_s+"-1"] = rig.crew_rig_wits_category_histogram(1,history)
    #   end
    #   return wits_category_histogram
    # end
    # def wells_wits_category_histogram(wells, history=-1)
    #   @wits_category_histogram = Hash.new
    #   wells.each do |well|
    #     @wits_category_histogram[well.id] = well.well_wits_category_histogram(history)
    #   end
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
    #       @wits_category_histogram[iterator] = Hash["data" => histo_data_arr, "ten_per" => ten_percent, "fifty_per" => fifty_percent.to_i, "ninety_per" => ninety_percent, "op_count" => total_count, "total_time" => (total_time / 60.0).round(2), "avg_time" => (average_time / 60.0).round(2), "max_op_time" => (max_operation_time / 60.0).round(2), "potential_saving" => potential_saving.round(4), "saving" => savings.round(2), "benchmark" => (Rig::BENCHMARK_TRIPPING_OUT_PIPE.to_f / 60).round(2)]
    #     else
    #       @wits_category_histogram[iterator] = Hash["data" => [{}], "ten_per" => 0, "fifty_per" => 0, "ninety_per" => 0, "op_count" => 0, "total_time" => 0, "avg_time" => 0, "max_op_time" => 0, "potential_saving" => 0]
    #     end
    #
    #   end
    #   # puts @wits_category_histogram
    #   return @wits_category_histogram
    # end
    #
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
    #       @wits_category_histogram[iterator] = Hash["data" => histo_data_arr, "ten_per" => ten_percent, "fifty_per" => fifty_percent.to_i, "ninety_per" => ninety_percent, "op_count" => total_count, "total_time" => (total_time / 60.0).round(2), "avg_time" => (average_time / 60.0).round(2), "max_op_time" => (max_operation_time / 60.0).round(2), "potential_saving" => potential_saving.round(4), "saving" => savings.round(2), "benchmark" => (Rig::BENCHMARK_TRIPPING_OUT_PIPE.to_f / 60).round(2)]
    #     else
    #       @wits_category_histogram[iterator] = Hash["data" => [{}], "ten_per" => 0, "fifty_per" => 0, "ninety_per" => 0, "op_count" => 0, "total_time" => 0, "avg_time" => 0, "max_op_time" => 0, "potential_saving" => 0]
    #     end
    #
    #   end
    #   # puts @wits_category_histogram
    #   return @wits_category_histogram
    # end
end
