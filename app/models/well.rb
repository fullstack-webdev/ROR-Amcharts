class Well < ActiveRecord::Base
  attr_accessible :name,
                  :location,
                  :hole_depth,
                  :total_time,
                  :total_time_morning,
                  :total_time_night,
                  :drilling_time,
                  :rop,
                  :drilling_rop,
                  :potential_savings,
                  :histogram,
                  :warnings_by_depth,
                  :depth_vs_time_logs,
                  :depth_vs_warnings_logs,
                  :footage_logs,
                  :depth_vs_cost_logs,
                  :started_at,
                  :finished_at,
                  :bottom_hole_location,
                  :county,
                  :drilling_company,
                  :fluid_company,
                  :well_number,
                  :api_number

  serialize :histogram
  serialize :warnings_by_depth
  serialize :depth_vs_time_logs
  serialize :depth_vs_warnings_logs
  serialize :footage_logs
  serialize :depth_vs_cost_logs

  acts_as_tenant(:company)

  before_save { |well| well.location = well.location.present? ? well.location.gsub('°', '').gsub("'", '') : "" }

  scope :completed, where('finished_at IS NOT NULL').order('finished_at ASC')

  validates :name, presence: true, length: {maximum: 50}
  validates_uniqueness_of :name, :case_sensitive => false, scope: :company_id
  validates :company, presence: true
  validates :rig, presence: true

  has_one :drilling_log
  belongs_to :company
  belongs_to :field
  belongs_to :rig
  has_and_belongs_to_many :programs, :autosave => true
  accepts_nested_attributes_for :programs
  belongs_to :offset_well, class_name: "Well"
  has_many :jobs, order: "close_date DESC, created_at DESC"
  has_many :warnings, through: :jobs, source: :event_warnings

  def self.search(search, company)
    terms = search.present? ? search.split : ""
    query = terms.map { |term| "name like %#{term}%" }.join(" OR ")

    return company.wells.where(query).order("name ASC").all
  end

  def self.search_with_field(options, company, field)
    query = options[:search].present? ? options[:search].downcase : options[:term].downcase

    return company.wells.where("LOWER(name) like '%"+query+"%'").order("name asc").all
  end

  def job
    self.jobs.first
  end

  def program
    self.programs.first
  end

  def complete
    self.hole_depth = job.total_depth || 0
    self.total_time = job.total_job_time || 0
    self.total_time_morning = job.total_job_time_by_crew(0) || 0
    self.total_time_night = job.total_job_time_by_crew(1) || 0
    self.drilling_time = job.drilling_time || 0
    self.rop = job.rop || 0
    self.drilling_rop = job.drilling_rop || 0
    self.potential_savings = job.potential_savings || 0
    self.histogram = job.wits_category_histogram
    self.started_at = job.start_date || 0
    self.finished_at = Time.zone.now.to_date
    self.warnings_by_depth = job.warnings_by_depth || 0
    self.depth_vs_time_logs = job.depth_vs_time_logs || 0
    self.depth_vs_warnings_logs = job.depth_vs_warnings_logs || 0
    self.footage_logs = job.footage_logs || 0
    self.depth_vs_cost_logs = job.depth_vs_cost_logs || 0
    self.save

    if self.program.present?
      program = self.program
      program.histogram = program.program_wits_category_histogram
      program.save
    end

    if self.rig.present?
      rig = self.rig
      rig.histogram = rig.rig_wits_category_histogram
      rig.save
    end
  end
  handle_asynchronously :complete

  def x_location
    decimal = location_decimal true
    puts 'x'
      puts decimal
      decimal
  end

  def y_location
      decimal = location_decimal false
      puts 'y'
      puts decimal
      decimal
  end

  # def total_well_time(crew = -1)
  #   last_log = ActiveRecord::Base.connection.execute("select max(wits_category_allocs.total_well_time) as total_well_time from wits_category_allocs left join jobs on jobs.id=wits_category_allocs.job_id left join wells on wells.id = jobs.well_id where wells.id = " + self.id.to_s + " group by wells.id").as_json
  #
  #   if last_log.empty?
  #     return 0
  #   else
  #     if crew == 0
  #       start_date = self.jobs.first.start_date
  #       first_day = (start_date.end_of_day - start_date) / 3600 / 24
  #       well_time = [(first_day - 0.5), 0].max
  #       complete_day = (last_log[0]['total_well_time'].to_f - first_day).to_i
  #       well_time = well_time + complete_day * 0.5
  #       last_day = [(last_log[0]['total_well_time'].to_f - first_day - complete_day), 0.5].minio
  #       well_time = well_time + last_day
  #       return well_time
  #     elsif crew == 1
  #       start_date = self.jobs.first.start_date
  #       first_day = (start_date.end_of_day - start_date) / 3600 / 24
  #       well_time = [first_day, 0.5].min
  #       complete_day = (last_log[0]['total_well_time'].to_f - first_day).to_i
  #       well_time = well_time + complete_day * 0.5
  #       last_day = [(last_log[0]['total_well_time'].to_f - first_day - complete_day - 0.5), 0].max
  #       well_time = well_time + last_day
  #       return well_time
  #     else
  #       return last_log[0]['total_well_time']
  #     end
  #   end
  # end

  # def finished_at
  #   last_log = ActiveRecord::Base.connection.execute("select wits_category_allocs.entry_at from wits_category_allocs left join jobs on jobs.id=wits_category_allocs.job_id left join wells on wells.id = jobs.well_id where wells.id = " + self.id.to_s + " order by wits_category_allocs.entry_at DESC limit 1").as_json
  #   if last_log.empty?
  #     return Time.now
  #   else
  #     return last_log[0]['entry_at'].to_time.to_i
  #   end
  # end

  # def started_at
  #   first_log = ActiveRecord::Base.connection.execute("select wits_category_allocs.entry_at from wits_category_allocs left join jobs on jobs.id=wits_category_allocs.job_id left join wells on wells.id = jobs.well_id where wells.id = " + self.id.to_s + " order by wits_category_allocs.entry_at limit 1").as_json
  #   if first_log.empty?
  #     return Time.now
  #   else
  #     return first_log[0]['entry_at'].to_time.to_i
  #   end
  # end

  # def total_depth
  #   last_log = ActiveRecord::Base.connection.execute("select max(wits_data.hole_depth) as hole_depth from wits_data left join jobs on jobs.id=wits_data.job_id left join wells on wells.id = jobs.well_id where wells.id = " + self.id.to_s + " group by wells.id").as_json
  #   if last_log.empty?
  #     return 0
  #   else
  #     return last_log[0]['hole_depth']
  #   end
  # end

  # def crew_total_depth(crew = -1)
  #   total_depth = 0.0
  #   wits_data_arr = self.jobs.first.wits_datas
  #   if wits_data_arr.count > 0
  #     if crew == 0
  #       start_date = wits_data_arr.first.entry_at
  #       last_date = wits_data_arr.last.entry_at
  #
  #       query_start_date = [start_date, (start_date.beginning_of_day + 6.hours)].max
  #       if query_start_date < start_date.beginning_of_day + 18.hours
  #         query_end_date = start_date.beginning_of_day + 18.hours
  #       else
  #         query_start_date = [query_start_date, start_date.beginning_of_day + 6.hours + 24.hours].max
  #         query_end_date = start_date.beginning_of_day + 18.hours + 24.hours
  #       end
  #       while (query_start_date < last_date)
  #         start_log = self.jobs.first.wits_datas.where("entry_at <= ?", query_start_date).last
  #         last_log = self.jobs.first.wits_datas.where("entry_at <= ?", query_end_date).last
  #         total_depth = total_depth + [(last_log.nil? ? "0.0" : last_log.hole_depth) - (start_log.nil? ? "0.0" : start_log.hole_depth), 0].max
  #
  #         query_start_date = query_end_date + 12.hours
  #         query_end_date = query_end_date + 24.hours
  #       end
  #       return total_depth
  #     elsif crew == 1
  #       start_date = wits_data_arr.first.entry_at
  #       last_date = wits_data_arr.last.entry_at
  #
  #       query_start_date = start_date.beginning_of_day + 6.hours
  #       if start_date < query_start_date
  #         query_end_date = query_start_date
  #         query_start_date = start_date
  #       else
  #         query_start_date = [start_date, (start_date.beginning_of_day + 18.hours)].max
  #         query_end_date = start_date.beginning_of_day + 30.hours
  #       end
  #       while (query_start_date < last_date)
  #         start_log = self.jobs.first.wits_datas.where("entry_at <= ?", query_start_date).last
  #         last_log = self.jobs.first.wits_datas.where("entry_at <= ?", query_end_date).last
  #         total_depth = total_depth + [(last_log.nil? ? "0.0" : last_log.hole_depth) - (start_log.nil? ? "0.0" : start_log.hole_depth), 0].max
  #         query_start_date = query_end_date + 12.hours
  #         query_end_date = query_end_date + 24.hours
  #       end
  #       return total_depth
  #     end
  #   else
  #     return 0.0
  #   end
  # end

  def vertical_depth
    return self.total_depth
  end

  def lateral_depth
    return '-'
  end

  # def drilling_time
  #   last_log = ActiveRecord::Base.connection.execute("select max(wits_category_allocs.drilling_time) as drilling_time from wits_category_allocs left join jobs on jobs.id=wits_category_allocs.job_id left join wells on wells.id = jobs.well_id where wells.id = " + self.id.to_s + " group by wells.id").as_json
  #   if last_log.empty?
  #     return 0
  #   else
  #     return last_log[0]['drilling_time']
  #   end
  # end

  # def crew_drilling_time(crew)
  #   total_time = 0.0
  #   wits_data_arr = self.jobs.first.wits_category_allocs
  #   if wits_data_arr.count > 0
  #     if crew == 0
  #       start_date = wits_data_arr.last.entry_at
  #       last_date = wits_data_arr.first.entry_at
  #       query_start_date = [start_date, (start_date.beginning_of_day + 6.hours)].max
  #       if query_start_date < start_date.beginning_of_day + 18.hours
  #         query_end_date = start_date.beginning_of_day + 18.hours
  #       else
  #         query_start_date = [query_start_date, start_date.beginning_of_day + 6.hours + 24.hours].max
  #         query_end_date = start_date.beginning_of_day + 18.hours + 24.hours
  #       end
  #       while (query_start_date < last_date)
  #         start_log = self.jobs.first.wits_category_allocs.where("entry_at <= ?", query_start_date).maximum(:drilling_time).to_f
  #         last_log = self.jobs.first.wits_category_allocs.where("entry_at <= ?", query_end_date).maximum(:drilling_time).to_f
  #         total_time = total_time + [(last_log - start_log), 0.0].max
  #         query_start_date = query_end_date + 12.hours
  #         query_end_date = query_end_date + 24.hours
  #       end
  #       return total_time
  #     elsif crew == 1
  #       start_date = wits_data_arr.last.entry_at
  #       last_date = wits_data_arr.first.entry_at
  #
  #       query_start_date = start_date.beginning_of_day + 6.hours
  #       if start_date < query_start_date
  #         query_end_date = query_start_date
  #         query_start_date = start_date
  #       else
  #         query_start_date = [start_date, (start_date.beginning_of_day + 18.hours)].max
  #         query_end_date = start_date.beginning_of_day + 30.hours
  #       end
  #       while (query_start_date < last_date)
  #         start_log = self.jobs.first.wits_category_allocs.where("entry_at <= ?", query_start_date).maximum(:drilling_time).to_f
  #         last_log = self.jobs.first.wits_category_allocs.where("entry_at <= ?", query_end_date).maximum(:drilling_time).to_f
  #         total_time = total_time + [(last_log - start_log), 0].max
  #         query_start_date = query_end_date + 12.hours
  #         query_end_date = query_end_date + 24.hours
  #       end
  #       return total_time
  #     end
  #   else
  #     return 0.0
  #   end
  #
  # end

  def well_day_cost
    self.rig.try(:day_cost) || 0
  end

  # def total_rop(crew = -1)
  #   if crew == -1
  #     return self.total_depth.to_f / (self.total_well_time.to_f.nonzero? || 1) / 24.0
  #   else
  #     return self.crew_total_depth(crew).to_f / (self.total_well_time(crew).to_f.nonzero? || 1)
  #   end
  # end

  # def drilling_rop(crew = -1)
  #   if crew == -1
  #     return self.total_depth.to_f / (self.drilling_time.to_f.nonzero? || 1) / 24.0
  #   else
  #     return self.crew_total_depth(crew).to_f / (self.crew_drilling_time(crew).to_f.nonzero? || 1)
  #   end
  # end

  # def total_cost(crew = -1)
  #   return (self.total_well_time(crew).to_f * (self.well_day_cost || 0)).round
  # end

  def total_cost
    (self.total_time || job.total_job_time) / 3600 / 24 * self.well_day_cost
  end

  def total_depth
    self.hole_depth || job.total_depth
  end

  def total_well_time
    self.total_time || job.total_job_time
  end

  def total_warnings
    warnings.length
  end

  # dummy
  def hole_size
    return ''
  end

  # dummy
  def predicted_well_time
    return nil
  end

  def savings_potential(crew = -1)
    if crew == -1
      savings = ActiveRecord::Base.connection.execute("select wits_category_lists.category_name as category_id, sum(wits_category_lists.operation_time) as duration, count(wits_category_lists.time_index) as operation_count from wits_category_lists left join jobs on jobs.id=wits_category_lists.job_id left join wells on wells.id = jobs.well_id where wells.id = " + self.id.to_s + " group by wits_category_lists.category_name").as_json
      savings_sum = 0
      savings.each do |saving|
        # puts saving.as_json
        savings_sum = savings_sum + saving['duration'].to_f - saving['operation_count'].to_i * self.rig.get_benchmark_target(saving['category_id']).to_f
      end
      return savings_sum / self.total_well_time.to_f / 60 / 60 / 24
    elsif crew == 0
      savings = ActiveRecord::Base.connection.execute("select wits_category_lists.category_name as category_id, sum(wits_category_lists.operation_time) as duration, count(wits_category_lists.time_index) as operation_count from wits_category_lists left join jobs on jobs.id=wits_category_lists.job_id left join wells on wells.id = jobs.well_id where (\"time\"(wits_category_lists.time_stamp)) > '06:00:00' and (\"time\"(wits_category_lists.time_stamp)) <= '18:00:00' and wells.id = " + self.id.to_s + " group by wits_category_lists.category_name").as_json
      savings_sum = 0
      savings.each do |saving|
        # puts saving.as_json
        savings_sum = savings_sum + saving['duration'].to_f - saving['operation_count'].to_i * self.rig.get_benchmark_target(saving['category_id']).to_f
      end
      return savings_sum / self.total_well_time.to_f / 60 / 60 / 24
    elsif crew == 1
      savings = ActiveRecord::Base.connection.execute("select wits_category_lists.category_name as category_id, sum(wits_category_lists.operation_time) as duration, count(wits_category_lists.time_index) as operation_count from wits_category_lists left join jobs on jobs.id=wits_category_lists.job_id left join wells on wells.id = jobs.well_id where (((\"time\"(wits_category_lists.time_stamp)) >= '00:00:00' and (\"time\"(wits_category_lists.time_stamp)) <= '06:00:00') or ((\"time\"(wits_category_lists.time_stamp)) > '18:00:00' and (\"time\"(wits_category_lists.time_stamp)) <= '23:59:59')) and wells.id = " + self.id.to_s + " group by wits_category_lists.category_name").as_json
      savings_sum = 0
      savings.each do |saving|
        # puts saving.as_json
        savings_sum = savings_sum + saving['duration'].to_f - saving['operation_count'].to_i * self.rig.get_benchmark_target(saving['category_id']).to_f
      end
      return savings_sum / self.total_well_time.to_f / 60 / 60 / 24
    end
  end

  def category_name_from_id(id)
    case id.to_i
      when 0
        return 'Tripping In (Connection)'
      when 1
        return 'Tripping In (Pipe Moving Time)'
      when 2
        return 'Tripping Out (Connection)'
      when 3
        return 'Tripping Out (Pipe Moving Time)'
      when 4
        return 'Drilling (Connection)'
      when 5
        return 'Drilling (Weight To Weight)'
      when 6
        return 'Drilling (Treatment)'
      when 7
        return 'Drilling (Drilling)'
    end
  end

  def general_activity_name_from_id(id)
    case id.to_i
      when 0
        return 'Out of Hole'
      when 1
        return 'Tripping in'
      when 2
        return 'Tripping out'
      when 3
        return 'Drilling'
      when 4
        return 'Other'
      when 5
        return 'Circulation'
    end
  end

  def current_category
    last_log = ActiveRecord::Base.connection.execute("select wits_category_lists.category_name as category_id from wits_category_lists left join jobs on jobs.id=wits_category_lists.job_id left join wells on wells.id = jobs.well_id where wells.id = " + self.id.to_s + " order by wits_category_lists.time_stamp DESC limit 1").as_json
    if last_log.empty? || last_log.nil?
      return ''
    else
      return self.category_name_from_id(last_log[0]['category_id'])
    end
  end

  # def current_gactivity
  #   last_log = ActiveRecord::Base.connection.execute("select wits_gactivities.activity as activity_id from wits_gactivities left join jobs on jobs.id=wits_gactivities.job_id left join wells on wells.id = jobs.well_id where wells.id = " + self.id.to_s + " order by wits_gactivities.start_time DESC limit 1").as_json
  #   if last_log.empty? || last_log.nil?
  #     return ''
  #   else
  #     return self.general_activity_name_from_id(last_log[0]['activity_id'])
  #   end
  # end
  #
  # def current_activity
  #   last_log = ActiveRecord::Base.connection.execute("select wits_activity_lists.activity_name as activity_name from wits_activity_lists left join jobs on jobs.id=wits_activity_lists.job_id left join wells on wells.id = jobs.well_id where wells.id = " + self.id.to_s + " order by wits_activity_lists.start_time DESC limit 1").as_json
  #   if last_log.empty? || last_log.nil?
  #     return ''
  #   else
  #     return last_log[0]['activity_name'].to_s
  #   end
  # end
  #
  # def bit_depth
  #   last_log = ActiveRecord::Base.connection.execute("select wits_data.bit_depth as bit_depth from wits_data left join jobs on jobs.id=wits_data.job_id left join wells on wells.id = jobs.well_id where wells.id = " + self.id.to_s + " order by wits_data.entry_at DESC limit 1").as_json
  #   if last_log.empty? || last_log.nil?
  #     return ''
  #   else
  #     return last_log[0]['bit_depth']
  #   end
  # end

  # def footage_logs
  #   logs = self.depth_logs
  #   for i in 1..(logs.count - 1)
  #     if logs[i] < logs[i - 1]
  #       logs[i] = logs[i - 1]
  #     end
  #   end
  #   for i in (logs.count - 1).downto(1)
  #     logs[i] = [(logs[i] - logs[i - 1]), 0].max
  #   end
  #   return logs
  # end

  # def depth_logs
  #   started_at = self.started_at
  #   results = []
  #   last_depth = 0
  #   for i in 0..self.total_well_time.to_f.round
  #     time_axis_from = started_at + (i-1)*24*60*60
  #     time_axis_to = started_at + i*24*60*60
  #     logs = ActiveRecord::Base.connection.execute("select wits_data.hole_depth as depth from wits_data left join jobs on jobs.id=wits_data.job_id left join wells on wells.id = jobs.well_id where wells.id = " + self.id.to_s + " and wits_data.entry_at > '" + Time.at(time_axis_from).to_s + "' and wits_data.entry_at < '" + Time.at(time_axis_to).to_s + "'").as_json
  #     if logs.empty?
  #       results<<last_depth
  #     else
  #       sum = 0
  #       max_depth = 0
  #       logs.each do |log|
  #         depth = log['depth'].to_f
  #         sum += depth
  #         if depth > max_depth
  #           max_depth = depth
  #         end
  #       end
  #       avg_depth = sum / logs.length
  #       if max_depth - avg_depth > 5000
  #         last_depth = avg_depth
  #         results<<avg_depth
  #       else
  #         last_depth = max_depth
  #         results<<max_depth
  #       end
  #     end
  #   end
  #   return results
  # end

  def performance_depth_logs
    started_at = self.started_at
    logs = []
    last_depth = 0
    for i in 0..self.total_well_time.to_f.round
      time_axis = started_at + i*24*60*60
      # last_log = ActiveRecord::Base.connection.execute("select max(wits_category_allocs.drilling_time) as drilling_time from wits_category_allocs left join jobs on jobs.id=wits_category_allocs.job_id left join wells on wells.id = jobs.well_id where wells.id = " + self.id.to_s + " group by wells.id").as_json
      log = ActiveRecord::Base.connection.execute("select wits_data.hole_depth as depth from wits_data left join jobs on jobs.id=wits_data.job_id left join wells on wells.id = jobs.well_id where wells.id = " + self.id.to_s + " and wits_data.entry_at < '" + Time.at(time_axis).to_s + "' order by wits_data.entry_at DESC limit 1").as_json
      if log.empty?
        logs<<last_depth
      else
        last_depth = [log[0]['depth'].to_f, last_depth].max
        logs<<last_depth
      end
    end
    return logs
  end

  def footage_logs_both_shifts
    logs = self.depth_logs_both_shifts
    output = []
    # for i in (logs[0].count - 1).downto(1)
    #   logs[0][i] = logs[0][i] - logs[0][i - 1]
    #   logs[1][i] = logs[1][i] - logs[1][i - 1]
    #
    # end
    for i in 0..(logs[0].count - 1)
      output << Hash["time" => i, "first_half" => logs[0][i], "second_half" => logs[1][i]]
    end
    return output
  end

  def depth_logs_both_shifts
    started_at = (self.job.start_date.beginning_of_day + 6.hours).to_i
    logs = [[], []]
    last_depth = 0
    for i in 0..self.job.total_days.to_f.round * 2 - 1
      time_axis = started_at + i*12*60*60
      log = ActiveRecord::Base.connection.execute("select wits_data.hole_depth as depth from wits_data left join jobs on jobs.id=wits_data.job_id left join wells on wells.id = jobs.well_id where wells.id = " + self.id.to_s + " and wits_data.entry_at < '" + Time.at(time_axis).to_s + "' order by wits_data.entry_at DESC limit 1").as_json
      if log.empty?
        logs[i % 2] << 0
      else
        logs[i % 2]<<([log[0]['depth'].to_f, last_depth].max - last_depth)
        last_depth = [log[0]['depth'].to_f, last_depth].max
        puts "======last_depth======"
        puts last_depth
      end
    end
    puts logs.to_json
    return logs
  end

  # def depth_vs_cost_logs
  #   started_at = self.started_at
  #   logs = []
  #   last_depth = 0
  #   tick = 50000
  #   x_axis = (self.total_well_time.to_f * self.well_day_cost.to_f / tick).round
  #   for i in 0..x_axis
  #     time_axis = started_at + 24 * 60 * 60 * i * tick / self.well_day_cost.to_f
  #     log = ActiveRecord::Base.connection.execute("select wits_data.hole_depth as depth from wits_data left join jobs on jobs.id=wits_data.job_id left join wells on wells.id = jobs.well_id where wells.id = " + self.id.to_s + " and wits_data.entry_at < '" + Time.at(time_axis).to_s + "' order by wits_data.entry_at DESC limit 1").as_json
  #     if log.empty?
  #       logs<<last_depth
  #     else
  #       last_depth = [log[0]['depth'].to_f, last_depth].max
  #       logs<<last_depth
  #     end
  #   end
  #   return logs
  # end

  def depth_vs_warning_logs
    started_at = self.started_at
    logs = []
    last_depth = 0
    tick = 50000
    x_axis = (self.total_well_time.to_f * self.well_day_cost.to_f / tick).round
    total_warnings = 0
    for i in 0..x_axis
      time_axis = started_at + 24 * 60 * 60 * i * tick / self.well_day_cost.to_f
      warning = Random.rand(2)
      puts "======warning===="
      puts warning

      if (i == 0 || warning == 1)
        log = ActiveRecord::Base.connection.execute("select wits_data.hole_depth as depth from wits_data left join jobs on jobs.id=wits_data.job_id left join wells on wells.id = jobs.well_id where wells.id = " + self.id.to_s + " and wits_data.entry_at < '" + Time.at(time_axis).to_s + "' order by wits_data.entry_at DESC limit 1").as_json
        if log.empty?
          logs<<last_depth
        else
          last_depth = [log[0]['depth'].to_f, last_depth].max
          logs<<last_depth
        end
      end
    end
    return logs
  end

  def activity_summary
    # search_from = Time.at(self.finished_at - 24*60*60*2)
    logs = ActiveRecord::Base.connection.execute("SELECT wits_gactivities.activity as activity_id,
                wits_gactivities.start_time as start_time, wits_gactivities.bit_depth
            FROM wits_gactivities
            left join jobs on jobs.id=wits_gactivities.job_id left join wells on wells.id = jobs.well_id
            WHERE wells.id = " + self.id.to_s + "
            ORDER BY wits_gactivities.start_time").as_json
    return logs
  end

  def related_jobs
    related_wells = []
    self.rig.wells.each do |well|
      unless well.id == self.id || well.id == self.offset_well_id || related_wells.length > 20
        related_wells << well
      end
    end
    return related_wells
  end

  def activity_time(days)
    log = []

    case days.to_i
      when -1
        log = ActiveRecord::Base.connection.execute("select sum(wits_activity_lists.operation_time) as activity_time from wits_activity_lists left join jobs on jobs.id=wits_activity_lists.job_id left join wells on wells.id = jobs.well_id where wells.id = " + self.id.to_s).as_json
      else
        search_from = self.last_activity_at - days * 24 * 60 * 60
        log = ActiveRecord::Base.connection.execute("select sum(wits_activity_lists.operation_time) as activity_time from wits_activity_lists left join jobs on jobs.id=wits_activity_lists.job_id left join wells on wells.id = jobs.well_id where wells.id = " + self.id.to_s + " and wits_activity_lists.start_time >= '" + Time.at(search_from).to_s + "'").as_json
    end

    if log.empty?
      return 0
    else
      return log[0]['activity_time']
    end
  end

  def last_activity_at
    log = ActiveRecord::Base.connection.execute("select wits_activity_lists.start_time as start_time from wits_activity_lists left join jobs on jobs.id=wits_activity_lists.job_id left join wells on wells.id = jobs.well_id where wells.id = " + self.id.to_s + " order by wits_activity_lists.start_time DESC limit 1").as_json
    if log.empty?
      return Time.now
    else
      return log[0]['start_time'].to_time.to_i
    end
  end

  def aggregate_activity(days)
    logs = []
    total_activity_time = self.activity_time(days).to_f

    case days.to_i
      when -1
        logs = ActiveRecord::Base.connection.execute("select sum(wits_activity_lists.operation_time) as activity_time, wits_activity_lists.activity_name as activity_name from wits_activity_lists left join jobs on jobs.id=wits_activity_lists.job_id left join wells on wells.id = jobs.well_id where wells.id = " + self.id.to_s + " group by wits_activity_lists.activity_name order by wits_activity_lists.activity_name").as_json
      else
        search_from = self.last_activity_at - days * 24 * 60 * 60
        logs = ActiveRecord::Base.connection.execute("SELECT sum(wits_activity_lists.operation_time) as activity_time,
                        wits_activity_lists.activity_name as activity_name
                        FROM wits_activity_lists left join jobs on jobs.id=wits_activity_lists.job_id left join wells on wells.id = jobs.well_id
                        WHERE wells.id = " + self.id.to_s + " and wits_activity_lists.start_time > '" + Time.at(search_from).to_s + "'
                        GROUP BY wits_activity_lists.activity_name order by wits_activity_lists.activity_name").as_json
    end

    agg_data = []

    logs.each do |log|
      color = ''
      case log['activity_name'].to_s
        when 'Other'
          color = '#D2DFD8'
        when 'Drilling Rotary'
          color = '#4840D1'
        when 'Drilling Slide'
          color = '#0085E3'
        when 'Connection'
          color = '#909F98'
        when 'Circulating'
          color = '#9500B7'
        when 'Run in Hole'
          color = '#F70000'
        when 'Run out of Hole'
          color = '#940000'
        when 'Washing Upwards'
          color = '#EFD34B'
        when 'Washing Downwards'
          color = '#E99100'
        when 'Reaming Upwards'
          color = '#38732E'
        when 'Reaming Downwards'
          color = '#5DD94B'
      end

      percentage = log['activity_time'].to_f / total_activity_time * 100

      hash = {}
      hash['color'] = color
      hash['percentage'] = percentage
      hash['activity_name'] = log['activity_name']

      agg_data << hash
    end

    return agg_data
  end

  def avg_depth(crew = -1)
    # depth_sum = 0
    # self.wells.each do |well|
    #   depth_sum = depth_sum + well.total_depth.to_f
    # end
    if crew == -1
      return self.total_depth.to_f
    else
      return self.crew_total_depth(crew).to_f
    end
  end

  def avg_lateral_depth(crew = -1)
    # depth_sum = 0
    # self.wells.each do |well|
    #   depth_sum = depth_sum + well.total_depth.to_f
    # end
    # return depth_sum / self.wells.length
    if crew == -1
      return self.total_depth.to_f
    else
      return self.crew_total_depth(crew).to_f
    end
  end

  def avg_total_rop
    # rop_sum = 0
    # self.wells.each do |well|
    #   rop_sum = rop_sum + well.total_rop.to_f
    # end
    # return rop_sum / self.wells.length
    return self.total_rop.to_f
  end

  def avg_drilling_rop
    # rop_sum = 0
    # self.wells.each do |well|
    #   rop_sum = rop_sum + well.drilling_rop.to_f
    # end
    # return rop_sum / self.wells.length
    return self.drilling_rop.to_f / 24.0
  end

  def gen_rand_color
    return "#" + ("%06x" % (rand * 0xffffff)).to_s
    # return "#58c9c2"
  end

  def total_program_time(crew = -1)
    # total_well_time = 0
    # self.wells.each do |well|
    #   total_well_time = total_well_time + well.total_well_time(crew)
    # end
    # return total_well_time.to_i
    return self.total_well_time(crew)
  end

  def well_wits_category_histogram(history=-1)
    @wits_category_histogram = Hash.new
    benchmark_arr = Array.new
    rig = self.rig
    benchmark_arr.push(rig.benchmark_tripping_in_connection, rig.benchmark_tripping_in_pipe, rig.benchmark_tripping_out_connection, rig.benchmark_tripping_out_pipe, rig.benchmark_connection, rig.benchmark_wtw, rig.benchmark_treatment, rig.benchmark_bottom)
    # benchmark_arr.push(40, 30, 40, 20, 80, 350, 230, 1400)

    job = self.jobs.first
    puts "============job id==========="
    puts job.id

    min_date = nil
    if history.to_i > 0
      min_date = DateTime.now - history.to_i.months
    end
    if history.to_i > 0
      if job.start_date >= min_date
        return job.wits_category_histogram
      else
        for iterator in 0..7
          @wits_category_histogram[iterator] = Hash["data" => [{"op_time" => 0, "op_count" => 0}], "ten_per" => 0, "fifty_per" => 0, "ninety_per" => 0, "op_count" => 0, "total_time" => 0, "avg_time" => 0, "max_op_time" => 0, "potential_saving" => 0, "saving" => 0, "benchmark" => (benchmark_arr[iterator].to_f / 60).round(2)]
        end
        return @wits_category_histogram
      end
    else
      return job.wits_category_histogram
    end

    # jobs = []
    # if history.to_i > 0
    #   jobs = self.jobs.where('start_date >= ?', min_date).collect { |e| e['id'] }
    # else
    #   jobs = self.jobs.collect { |e| e['id'] }
    # end
    #
    # # jobs = jobs.uniq
    # total_programs_time = 0.0
    # jobs.each do |job|
    #   total_programs_time = total_programs_time + Job.find(job).total_job_time
    # end
    # for iterator in 0..7
    #   @wits_category_list = WitsCategoryList.where("job_id IN (?) and category_name = ?", jobs, iterator).order("operation_time asc")
    #
    #   if @wits_category_list.present?
    #     total_time = @wits_category_list.sum(:operation_time)
    #     total_count = @wits_category_list.count
    #     average_time = (total_time.to_f / total_count.to_f).round(2)
    #     time_break = 15
    #
    #     max_operation_time = @wits_category_list.maximum(:operation_time).to_i
    #
    #     tmp_histo_data_arr = Array.new(max_operation_time / time_break + 1) { |e| e = 0 }
    #
    #     @wits_category_list.each do |category|
    #       tmp_histo_data_arr[category.operation_time / time_break] += 1
    #     end
    #     histo_data_arr = Array.new
    #     for index in 0..((average_time.to_i / time_break).to_i + 1)
    #       histo_data_arr[index] = Hash["op_time" => (index + 1) * 0.25, "op_count" => tmp_histo_data_arr[index]]
    #     end
    #
    #     ten_percent = @wits_category_list.limit(total_count.to_i / 10).collect(&:operation_time).max
    #     fifty_percent = @wits_category_list.limit(total_count.to_i * 5 / 10).collect(&:operation_time).max
    #     ninety_percent = @wits_category_list.limit(total_count.to_i * 9 / 10).collect(&:operation_time).max
    #
    #     savings = [(total_time - total_count * benchmark_arr[iterator.to_i]), 0].max.to_f / 60.0 / 60.0 / 24.0
    #     potential_saving = savings * 100 / total_programs_time.to_f
    #     puts potential_saving
    #
    #     @wits_category_histogram[iterator] = Hash["data" => histo_data_arr, "ten_per" => ten_percent.to_f, "fifty_per" => fifty_percent.to_f, "ninety_per" => ninety_percent.to_f, "op_count" => total_count, "total_time" => (total_time / 60.0).round(2), "avg_time" => (average_time / 60.0).round(2), "max_op_time" => (max_operation_time / 60.0).round(2), "potential_saving" => potential_saving.round(2), "saving" => savings.round(2), "benchmark" => (benchmark_arr[iterator].to_f / 60).round(2)]
    #   else
    #     @wits_category_histogram[iterator] = Hash["data" => [{"op_time" => 0, "op_count" => 0}], "ten_per" => 0, "fifty_per" => 0, "ninety_per" => 0, "op_count" => 0, "total_time" => 0, "avg_time" => 0, "max_op_time" => 0, "potential_saving" => 0, "saving" => 0, "benchmark" => (benchmark_arr[iterator].to_f / 60).round(2)]
    #   end
    # end
    # return @wits_category_histogram
  end

  def cache_key
    job = self.jobs.try(:first)
    if job.present?
      WitsRecord.table_name = "wits_records#{job.id}"
      max_updated_at = WitsRecord.maximum(:updated_at).try(:utc).try(:to_s, :number)
      count = WitsRecord.count(:all)
      "jobs/#{job.id}-#{count}-#{max_updated_at}"
    end
  end

  private

  def location_decimal(first)
    if !self.location.blank?
      begin
        number = first ? self.location.split(',')[0] : self.location.split(',')[1]
        part = number.split(' ')
        if part.length == 4
          number = first ? self.location.split(',')[0] : self.location.split(',')[1]
          part = number.split(' ')
          decimal = part[0].to_f + (part[1].to_f / 60) + (part[2].to_f / 3600)
          if part[3].downcase == 'w' || part[3].downcase == 's' || part[3].downcase == 'west' || part[3].downcase == 'south'
            decimal *= -1
          end
          puts "............"
          puts decimal
          return decimal
        elsif part.length == 1
          return number.to_f
          #part.include?("'")
        end
      rescue
      end
    end

    0.0
  end

end
