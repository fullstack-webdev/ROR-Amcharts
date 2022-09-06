class Program < ActiveRecord::Base
  attr_accessible :name,
                  :histogram


  serialize :histogram

  acts_as_tenant(:company)

  validates :name, presence: true, length: {maximum: 50}

  has_many :rigs
  has_and_belongs_to_many :wells, :conditions => ['wells.finished_at IS NOT NULL'], :order => 'finished_at ASC'
  # has_many :wits_category_allocs, :through => :wells
  # has_many :wits_activity_lists, :through => :wells
  # has_many :wits_gactivities, :through => :wells
  # has_many :wits_datas, :through => :wells
  has_many :jobs, :through => :wells
  has_many :wits_category_lists, :through => :jobs
  belongs_to :company

  def avg_depth
    depth_sum = 0
    self.wells.each do |well|
      depth_sum = depth_sum + well.job.total_depth.to_f
    end
    return depth_sum / self.wells.length
  end

  def avg_lateral_depth
    depth_sum = 0
    self.wells.each do |well|
      depth_sum = depth_sum + well.job.total_depth.to_f
    end
    return depth_sum / self.wells.length
  end

  def avg_total_rop
    rop_sum = 0
    self.wells.each do |well|
      rop_sum = rop_sum + well.job.rop.to_f
    end
    return rop_sum / self.wells.length
  end

  def avg_drilling_rop
    rop_sum = 0
    self.wells.each do |well|
      rop_sum = rop_sum + well.job.drilling_rop.to_f
    end
    return rop_sum / self.wells.length
  end

  def gen_rand_color
    # return "#" + ("%06x" % (rand * 0xffffff)).to_s
    return "#58c9c2"
  end

  def total_program_time()
    total_well_time = 0
    self.wells.each do |well|
      total_well_time = total_well_time + well.job.total_job_time
    end
    return total_well_time.to_i
  end

  # def program_wits_category_histogram(history=-1)
  #   @wits_category_histogram = Hash.new
  #   benchmark_arr = Array.new
  #   benchmark_arr.push(40, 30, 40, 20, 80, 350, 230, 1400)
  #
  #   min_date = nil
  #   if history.to_i > 0
  #     min_date = DateTime.now - history.to_i.months
  #   end
  #   # jobs = []
  #   if history.to_i > 0
  #     jobs = self.jobs.where('start_date >= ?', min_date).collect {|e| e['id']}
  #   else
  #     jobs = self.jobs.collect {|e| e['id']}
  #   end
  #
  #   # jobs = jobs.uniq
  #   total_programs_time = 0.0
  #   jobs.each do |job|
  #     total_programs_time = total_programs_time + Job.find(job).total_job_time
  #   end
  #   for iterator in 0..7
  #     @wits_category_list = WitsCategoryList.where("job_id IN (?) and category_name = ?", jobs, iterator).order("operation_time asc")
  #
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
  #       potential_saving = savings * 100 / total_programs_time.to_f
  #       puts potential_saving
  #
  #       @wits_category_histogram[iterator] = Hash["data" => histo_data_arr, "ten_per" => ten_percent, "fifty_per" => fifty_percent.to_i, "ninety_per" => ninety_percent, "op_count" => total_count, "total_time" => (total_time / 60.0).round(2), "avg_time" => (average_time / 60.0).round(2), "max_op_time" => (max_operation_time / 60.0).round(2), "potential_saving" => potential_saving.round(2), "saving" => savings.round(2), "benchmark" => (benchmark_arr[iterator].to_f / 60).round(2)]
  #     else
  #       @wits_category_histogram[iterator] = Hash["data" => [{"op_time"=>0, "op_count"=>0}], "ten_per" => 0, "fifty_per" => 0, "ninety_per" => 0, "op_count" => 0, "total_time" => 0, "avg_time" => 0, "max_op_time" => 0, "potential_saving" => 0, "saving" => 0, "benchmark" => (benchmark_arr[iterator].to_f / 60).round(2)]
  #     end
  #
  #   end
  #   return @wits_category_histogram
  # end

  def program_wits_category_histogram(history=-1)
    data = {}
    benchmark_arr = [40, 30, 40, 20, 80, 350, 230, 1400]
    time_break = 15
    if history.to_i > 0
      wells = self.wells.where('finished_at >= ?', DateTime.now - history.to_i.months)
    else
      wells = self.wells
    end
    return nil if wells.empty?
    total_program_time = 0
    wells.each { |w| total_program_time += w.total_time }
    for iterator in 0..7
      total_time = 0
      total_count = 0
      max_operation_time = 0
      tmp_histo_data_arr = {}
      wells.each do |well|
        histogram = well.histogram[iterator]
        next if histogram.nil?
        total_time += histogram['total_time']
        total_count += histogram['op_count']
        max_operation_time = [max_operation_time, histogram['max_op_time']].max
        histogram['data'].each_with_index do |value, index|
          tmp_histo_data_arr[value['op_time']] = (tmp_histo_data_arr[value['op_time']] || 0) + value['op_count']
        end
      end
      average_time = total_time.to_f / (total_count.nonzero? || 1)
      histo_data_arr = []
      # ten_percent = nil
      # fifty_percent = nil
      # ninety_percent = nil
      # counter = 0
      tmp_histo_data_arr.sort_by {|key, vale| key}.each do |key, value|
        histo_data_arr << Hash["op_time" => key, "op_count" => value]
        # counter += value
        # if ten_percent.nil? && counter > total_count / 10
        #   ten_percent = key * 60
        # elsif fifty_percent.nil? && counter > total_count / 2
        #   fifty_percent = key * 60
        # elsif ninety_percent.nil? && counter > total_count / 10 * 9
        #   ninety_percent = key * 60
        # end
      end
      ten_percent = self.wits_category_lists.where(category_name: iterator).reorder('operation_time ASC').limit(total_count / 10).select('operation_time').try(:last).try(:operation_time)
      fifty_percent = self.wits_category_lists.where(category_name: iterator).reorder('operation_time ASC').limit(total_count / 2).select('operation_time').try(:last).try(:operation_time)
      ninety_percent = self.wits_category_lists.where(category_name: iterator).reorder('operation_time ASC').limit(total_count / 10 * 9).select('operation_time').try(:last).try(:operation_time)
      savings = [(total_time - total_count * benchmark_arr[iterator]), 0].max / 60.0 / 60.0 / 24.0
      potential_saving = savings * 100 / (total_program_time / 3600.0 / 24.0)
      data[iterator] = {
          "data" => histo_data_arr,
          "ten_per" => ten_percent || 0,
          "fifty_per" => fifty_percent || 0,
          "ninety_per" => ninety_percent || 0,
          "op_count" => total_count,
          "total_time" => total_time,
          "avg_time" => average_time,
          "max_op_time" => max_operation_time,
          "potential_saving" => potential_saving,
          "saving" => savings,
          "benchmark" => benchmark_arr[iterator]
      }
    end
    return data
  end
end
