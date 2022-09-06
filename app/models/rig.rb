class Rig < ActiveRecord::Base
  attr_accessible :name,
                  :rig_memberships_count,
                  :benchmark_wtw,
                  :benchmark_connection,
                  :benchmark_treatment,
                  :benchmark_bottom,
                  :benchmark_tripping_in_connection,
                  :benchmark_tripping_in_pipe,
                  :benchmark_tripping_out_connection,
                  :benchmark_tripping_out_pipe,
                  :day_cost,
                  :program_id,
                  :offset_well_id,
                  :histogram,
                  :block_weight


  serialize :histogram

  acts_as_tenant(:company)

  validates :name, presence: true, length: {maximum: 50}
  validates_uniqueness_of :name, :case_sensitive => false, scope: :company_id
  validates_presence_of :company

  belongs_to :company

  belongs_to :program
  belongs_to :offset_well, class_name: "Well"
  has_many :wells
  has_many :jobs, :through=>:wells
  has_many :wits_category_lists, :through => :jobs
  has_many :rig_memberships, dependent: :destroy, foreign_key: "rig_id", order: "created_at ASC"
  has_many :members, through: :rig_memberships, source: :user

  BENCHMARK_WTW = 350
  BENCHMARK_CONNECTION = 80
  BENCHMARK_TREATMENT = 230
  BENCHMARK_BOTTOM = 1400
  BENCHMARK_TRIPPING_IN_CONNECTION = 40
  BENCHMARK_TRIPPING_IN_PIPE = 30
  BENCHMARK_TRIPPING_OUT_CONNECTION = 40
  BENCHMARK_TRIPPING_OUT_PIPE = 20

  def current_job
    Job.includes(well: :programs).where("wells.rig_id = ?", self.id).order("jobs.created_at").last
  end

  def self.search(options, company)
    query = options[:search].present? ? options[:search].downcase : options[:term].downcase

    return company.rigs.where("LOWER(name) like '%"+query+"%'").order("name asc").all
  end

  def color
    if !self.name.blank?
      Digest::MD5.hexdigest(self.name)[0..5]
    else
      '666666'
    end
  end

  def self.get_rig_rop rig_id, time_range
    months = []
    result = DrillingLog.joins(job: {well: :rig}).where("rigs.id = ?", rig_id).where("drilling_logs.updated_at >= ?", Date.today - 1.year).select("coalesce(drilling_logs.drilling_rop, 0) AS rop, coalesce(drilling_logs.rotate_rop, 0) AS rotate_rop, coalesce(drilling_logs.slide_rop, 0) AS slide_rop, drilling_logs.updated_at as date, drilling_logs.npt as npt, drilling_logs.total_time as total_time, rigs.name as rig_name, jobs.failures_count as failures")
    result = result.group_by { |d| Date.strptime(d.date, '%Y-%m-%d').month }

    12.times do |m|
      months << {month: Date::MONTHNAMES[m + 1]}
    end
    result.each do |group|
      hash = months[group[0] - 1]

      if group[1].any?
        count = group[1].count
        rop = 0
        rotate = 0
        slide = 0
        npt = 0
        total_time = 0
        group[1].each do |dl|
          rop += dl[:rop]
          rotate += dl[:rotate_rop]
          slide += dl[:slide_rop]
          npt += dl[:npt]
          total_time += dl[:total_time].to_f
        end

        hash[:rop] = (rop / count.to_f).round(1)
        hash[:rotate_rop] = (rotate / count.to_f).round(1)
        hash[:slide_rop] = (slide / count.to_f).round(1)
        hash[:npt] = (npt / total_time.to_f * 100).round(1)
      end
    end

    months
  end

  def self.get_rig_rops time_range
    months = []
    result = DrillingLog.joins(job: {well: :rig}).where("drilling_logs.updated_at >= ?", Date.today - 1.year).select("coalesce(drilling_logs.drilling_rop, 0) AS rop, drilling_logs.updated_at as date, wells.rig_id as rig_id, drilling_logs.npt as npt, coalesce(drilling_logs.total_time, 0) as total_time, rigs.name as rig_name, coalesce(jobs.failures_count, 0) as failures, coalesce(drilling_logs.max_depth, 0) as max_depth, coalesce(jobs.total_cost, 0) as cost")
    result = result.group_by { |d| Date.strptime(d.date, '%Y-%m-%d').month }

    12.times do |m|
      months << {month: Date::MONTHNAMES[m + 1]}
    end
    result.each do |group|
      hash = months[group[0] - 1]

      rigs = group[1].group_by { |dl| dl[:rig_name] }

      avg_rop = 0

      npt = 0
      max_depth = 0
      cost = 0
      total_time = 0
      group[1].each do |dl|
        avg_rop += dl[:rop]
        npt += dl[:npt]
        total_time += dl[:total_time].to_f
        max_depth += dl[:max_depth].to_f
        cost += dl[:cost].to_i
      end
      if group[1].any?
        hash[:avg_rop] = (avg_rop.to_f / group[1].length.to_f).round(1)
        hash[:npt] = (npt / total_time.to_f * 100).round(1)
        hash[:cost] = (cost.to_f / max_depth.to_f).round(2)
      end

      rigs.each do |rig_group|
        sum = 0
        rig_group[1].each do |r|
          sum += r[:rop]
        end
        hash[rig_group[0]] = (sum.to_f / rig_group[1].count.to_f).round(1)
      end
    end

    months
  end

  def self.get_rig_costs time_range
    months = []
    result = DrillingLog.joins(job: {well: :rig}).where("drilling_logs.updated_at >= ?", Date.today - 1.year).select("coalesce(drilling_logs.drilling_rop, 0) AS rop, drilling_logs.updated_at as date, wells.rig_id as rig_id, drilling_logs.npt as npt, coalesce(drilling_logs.total_time, 0) as total_time, rigs.name as rig_name, coalesce(jobs.failures_count, 0) as failures, coalesce(drilling_logs.max_depth, 0) as max_depth, coalesce(jobs.total_cost, 0) as cost")
    result = result.group_by { |d| Date.strptime(d.date, '%Y-%m-%d').month }

    12.times do |m|
      months << {month: Date::MONTHNAMES[m + 1]}
    end
    result.each do |group|
      hash = months[group[0] - 1]

      rigs = group[1].group_by { |dl| dl[:rig_name] }

      avg_rop = 0
      npt = 0
      max_depth = 0
      cost = 0
      total_time = 0
      group[1].each do |dl|
        avg_rop += dl[:rop]
        npt += dl[:npt]
        total_time += dl[:total_time].to_f
        max_depth += dl[:max_depth].to_f
        cost += dl[:cost].to_i
      end
      if group[1].any?
        hash[:avg_rop] = (avg_rop.to_f / group[1].length.to_f).round(1)
        hash[:npt] = (npt / total_time.to_f * 100).round(1)
        hash[:cost] = (cost.to_f / max_depth.to_f).round(2)
      end

      rigs.each do |rig_group|
        cost = 0
        feet = 0
        rig_group[1].each do |r|
          cost += r.cost.to_f
          feet += r.max_depth.to_f
        end
        hash[rig_group[0]] = (cost / feet).round(2)
      end
    end

    months
  end

  def get_benchmark_target(category_id)
    benchmarks = [self.benchmark_tripping_in_connection, self.benchmark_tripping_in_pipe, self.benchmark_tripping_out_connection, self.benchmark_tripping_out_pipe, self.benchmark_connection, self.benchmark_wtw, self.benchmark_treatment, self.benchmark_bottom]
    return benchmarks[category_id.to_i % 8]
  end

  def avg_depth(crew = -1)
    total_depth = self.wells.inject {|sum, w| sum + w.job.total_depth(crew)}
    total_depth / self.wells.length
  end

  def avg_lateral_depth(crew = -1)
    avg_depth(crew)
  end

  def avg_total_rop(crew = -1)
    total_rop = self.wells.inject {|sum, w| sum + w.job.rop(crew)}
    total_rop / self.wells.length
  end

  def avg_drilling_rop(crew = -1)
    total_rop = self.wells.inject {|sum, w| sum + w.job.drilling_rop(crew)}
    total_rop / self.wells.length
  end

  def gen_rand_color
    return "#" + ("%06x" % (rand * 0xffffff)).to_s
    # return "#58c9c2"
  end

  def total_program_time(crew = -1)
    self.wells.inject {|sum, w| sum + w.job.total_job_time(crew)}
  end

  def rig_wits_category_histogram(history=-1)
    data = {}
    time_break = 15
    if history.to_i > 0
      wells = self.wells.completed.where('finished_at >= ?', DateTime.now - history.to_i.months)
    else
      wells = self.wells.completed
    end
    return nil if wells.empty?
    total_program_time = 0
    wells.each { |w| total_program_time += w.total_time }
    for iterator in 0..7
      benchmark = get_benchmark_target(iterator)
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
      savings = [(total_time - total_count * benchmark), 0].max / 60.0 / 60.0 / 24.0
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
          "benchmark" => benchmark
      }
    end
    return data
  end

  def crew_rig_wits_category_histogram(crew, history=-1)
    @wits_category_histogram = Hash.new
    benchmark_arr = Array.new
    benchmark_arr.push(40, 30, 40, 20, 80, 350, 230, 1400)

    min_date = nil
    if history.to_i > 0
      min_date = DateTime.now - history.to_i.months
    end
    # jobs = []
    if history.to_i > 0
      jobs = self.jobs.where('start_date >= ?', min_date).collect {|e| e['id']}
    else
      jobs = self.jobs.collect {|e| e['id']}
    end

    # jobs = jobs.uniq
    total_programs_time = 0.0
    jobs.each do |job|
      total_programs_time = total_programs_time + Job.find(job).total_job_time
    end
    for iterator in 0..7
      if crew == 0
        @wits_category_list = WitsCategoryList.where("job_id IN (?) and category_name = ? and (\"time\"(time_stamp)) > ? and (\"time\"(time_stamp)) <= ?", jobs, iterator, '06:00:00', '18:00:00').order("operation_time asc")
      else
        @wits_category_list = WitsCategoryList.where("job_id IN (?) and category_name = ? and (((\"time\"(time_stamp)) >= ? and (\"time\"(time_stamp)) <= ?) or ((\"time\"(time_stamp)) > ? and (\"time\"(time_stamp)) <= ?))", jobs, iterator, '00:00:00', '06:00:00', '18:00:00', '23:59:59').order("operation_time asc")
      end


      if @wits_category_list.present?
        total_time = @wits_category_list.sum(:operation_time)
        total_count = @wits_category_list.count
        average_time = (total_time.to_f / total_count.to_f).round(2)
        time_break = 15

        max_operation_time = @wits_category_list.maximum(:operation_time).to_i

        tmp_histo_data_arr = Array.new(max_operation_time / time_break + 1) {|e| e = 0}

        @wits_category_list.each do |category|
          tmp_histo_data_arr[category.operation_time / time_break] += 1
        end
        histo_data_arr = Array.new
        for index in 0..((average_time.to_i / time_break).to_i + 1)
          histo_data_arr[index] = Hash["op_time"=>(index + 1) * 0.25, "op_count"=>tmp_histo_data_arr[index]]
        end

        ten_percent = @wits_category_list.limit(total_count.to_i / 10).collect(&:operation_time).max
        fifty_percent = @wits_category_list.limit(total_count.to_i * 5 / 10).collect(&:operation_time).max
        ninety_percent = @wits_category_list.limit(total_count.to_i * 9 / 10).collect(&:operation_time).max

        savings = [(total_time - total_count * benchmark_arr[iterator.to_i]), 0].max.to_f / 60.0 / 60.0 / 24.0
        potential_saving = savings * 100 / total_programs_time.to_f
        puts potential_saving

        @wits_category_histogram[iterator] = Hash["data" => histo_data_arr, "ten_per" => ten_percent.to_f, "fifty_per" => fifty_percent.to_f, "ninety_per" => ninety_percent.to_f, "op_count" => total_count, "total_time" => (total_time / 60.0).round(2), "avg_time" => (average_time / 60.0).round(2), "max_op_time" => (max_operation_time / 60.0).round(2), "potential_saving" => potential_saving.round(2), "saving" => savings.round(2), "benchmark" => (benchmark_arr[iterator].to_f / 60).round(2)]
      else
        @wits_category_histogram[iterator] = Hash["data" => [{"op_time"=>0, "op_count"=>0}], "ten_per" => 0, "fifty_per" => 0, "ninety_per" => 0, "op_count" => 0, "total_time" => 0, "avg_time" => 0, "max_op_time" => 0, "potential_saving" => 0, "saving" => 0, "benchmark" => (benchmark_arr[iterator].to_f / 60).round(2)]
      end

    end
    return @wits_category_histogram
  end
end
