class Job < ActiveRecord::Base
  require 'rubygems'
  require 'roo'
  require "uri"
  require "net/http"
  require 'enumerable/standard_deviation'

  attr_accessible :start_date,
                  :end_date,
                  :close_date,
                  :status,
                  :rating,
                  :job_number,
                  :api_number,
                  :inventory_notes,
                  :inventory_confirmed,
                  :failures_count,
                  # :total_cost,
                  :proposed_cost,
                  :perfect_well_ratio,
                  :shared,
                  :horizontal_deviation,
                  :section_last_entry_processed,
                  :section_intermediate_start,
                  :section_curve_start,
                  :section_tangent_start,
                  :section_drop_start,
                  :time_step

  include PostJobReportHelper

  acts_as_xlsx

  after_commit :flush_cache
  before_create :set_start_date

  acts_as_tenant(:company)

  validates_presence_of :company
  validates_presence_of :district_id
  validates_presence_of :well_id
  validates :inventory_notes, length: {maximum: 500}

  belongs_to :company
  belongs_to :district
  belongs_to :field
  belongs_to :well
  # has_many :dynamic_fields, dependent: :destroy, order: "ordering ASC"
  # has_many :documents, dependent: :destroy, order: "ordering ASC"
  has_many :job_memberships, dependent: :destroy, foreign_key: "job_id", order: "created_at ASC"
  # has_many :participants, through: :job_memberships, source: :user
  # has_many :unique_participants, through: :job_memberships, source: :user, uniq: true
  # has_many :alerts, dependent: :destroy
  # has_many :activities, dependent: :destroy
  has_many :job_costs, dependent: :destroy, order: "job_costs.charge_at ASC"
  has_many :wits_category_allocs, order: "entry_at DESC"
  has_many :wits_category_lists, order: "time_stamp ASC"
  has_many :wits_activity_lists, order: "start_time ASC"
  has_many :wits_gactivities, order: "start_time ASC"
  has_many :wits_data, order: "entry_at ASC", class_name: "WitsData"
  has_many :wits_histograms
  has_many :event_warnings, order: "opened_at DESC"
  has_many :bit
  has_many :casing
  has_many :drilling_string
  has_many :annotations, order: "start_time ASC", :conditions => ['annotations.event_warning_id IS NULL']


  ACTIVE = 1
  PRE_JOB = 5
  ON_JOB = 6
  POST_JOB = 7
  COMPLETE = 50
  ABANDONED = 100
  RERUN = 40


  SECTION_VERTICAL = 0
  SECTION_INTERMEDIATE = 1
  SECTION_CURVE = 2
  SECTION_TANGENT = 3
  SECTION_DROP = 4
  SECTION_TOTAL = 5


  def category_name_from_id(id = -1)
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
      else
        return ''
    end
  end

  def set_start_date
    self.start_date = Time.zone.now.to_date
  end

  def wits_analysis_data(query_date)
    if query_date == -1
      @last_wits_cat_alloc = self.wits_category_allocs.first
      @wits_act_alloc = WitsActivityList.where(:job_id => self.id).group(:activity_name).sum(:operation_time)
      @wits_act_total_time = WitsActivityList.where(:job_id => self.id).sum(:operation_time)
      @wits_activity_list = WitsActivityList.where(:job_id => self.id).order("start_time asc")
      @well_time_arr = {"productive_time" => 0, "invisible_time" => 0, "down_time" => 0}

      @wits_activity_list.each do |act_list|
        duration = act_list.operation_time
        case act_list.activity_name
          when "Drilling Rotary", "Drilling Slide"
            @well_time_arr["productive_time"] = @well_time_arr["productive_time"] + duration
          when "Connection", "Circulating", "Run in Hole", "Run out of Hole", "Washing Upwards", "Washing Downwards", "Reaming Upwards", "Reaming Downwards"
            @well_time_arr["invisible_time"] = @well_time_arr["invisible_time"] + duration
          when "Other"
            if duration >= 300
              @well_time_arr["down_time"] = @well_time_arr["down_time"] + duration
            else
              @well_time_arr["invisible_time"] = @well_time_arr["invisible_time"] + duration
            end
        end
      end

      if (@well_time_arr['productive_time'] + @well_time_arr['invisible_time'] + @well_time_arr['down_time']).to_f != 0
        @well_time_arr['productive_per'] = (@well_time_arr['productive_time'].to_f / (@well_time_arr['productive_time'] + @well_time_arr['invisible_time'] + @well_time_arr['down_time']).to_f * 100 * 100).to_i / 100.0
      else
        @well_time_arr['productive_per'] = 0
      end

      if (@well_time_arr['productive_time'] + @well_time_arr['invisible_time'] + @well_time_arr['down_time']).to_f != 0
        @well_time_arr['invisible_per'] = (@well_time_arr['invisible_time'].to_f / (@well_time_arr['productive_time'] + @well_time_arr['invisible_time'] + @well_time_arr['down_time']).to_f * 100 * 100).to_i / 100.0
      else
        @well_time_arr['invisible_per'] = 0
      end

      if (@well_time_arr['productive_time'] + @well_time_arr['invisible_time'] + @well_time_arr['down_time']).to_f != 0
        @well_time_arr['down_per'] = (@well_time_arr['down_time'].to_f / (@well_time_arr['productive_time'] + @well_time_arr['invisible_time'] + @well_time_arr['down_time']).to_f * 100 * 100).to_i / 100.0
      else
        @well_time_arr['down_per'] = 0
      end

      # return Hash["total_time" => @wits_act_total_time, "well_time" => @well_time_arr, "act_arr" => @wits_act_arr, "act_alloc" => @wits_act_alloc, "start_time" => @disp_start_date, "category_histogram" => self.wits_category_histogram(query_date), "act_summary_arr" => self.activity_summary_json(@disp_start_date)]
      return Hash["total_time" => @wits_act_total_time, "well_time" => @well_time_arr, "act_arr" => @wits_act_arr, "act_alloc" => @wits_act_alloc, "start_time" => "-1", "act_summary_arr" => []]
    else
      @last_wits_cat_alloc = self.wits_category_allocs.first

      if self.wits_activity_lists.present?
        # @wits_act_start_date = self.wits_activity_lists.first.start_time
        # query_date = self.wits_activity_lists.first.start_time
        # query_date = self.wits_activity_lists.last.start_time - 11.days
        @disp_start_date = query_date.beginning_of_day
        @disp_end_date = query_date.end_of_day

        @tmp_act = WitsActivityList.where("job_id=? and start_time <= ?", self.id, query_date.beginning_of_day).order("start_time desc").first
        if @tmp_act.present?
          @query_start_date = WitsActivityList.where("job_id=? and start_time <= ?", self.id, query_date.beginning_of_day).order(" start_time desc").first.start_time
          if !@query_start_date.present?
            @query_start_date = query_date.beginning_of_day
          end
          @query_end_date = query_date.end_of_day
          # @wits_act_alloc = WitsActivityList.where(:job_id => self.id, :time_stamp => @query_start_date..@query_end_date).group(:activity_name).sum(:operation_time)
        else
          @query_start_date = query_date.beginning_of_day
          @query_end_date = query_date.end_of_day
        end

        @wits_act_alloc = WitsActivityList.where(:job_id => self.id, :start_time => @query_start_date..@query_end_date).group(:activity_name).sum(:operation_time)
        @wits_act_total_time = WitsActivityList.where(:job_id => self.id, :start_time => @query_start_date..@query_end_date).sum(:operation_time)
        @wits_activity_list = WitsActivityList.where(:job_id => self.id, :start_time => @query_start_date..@query_end_date).order("start_time asc")

        if @disp_start_date.to_datetime > @wits_activity_list.first.start_time.to_datetime
          @wits_act_total_time = @wits_act_total_time - ((@disp_start_date.to_datetime - @wits_activity_list.first.start_time.to_datetime) * 24 * 3600).to_i
          @wits_act_alloc[@wits_activity_list.first.activity_name] = @wits_act_alloc[@wits_activity_list.first.activity_name] - ((@disp_start_date.to_datetime - @wits_activity_list.first.start_time.to_datetime) * 24 * 3600).to_i
        end

        date_iterator = query_date.beginning_of_day.to_datetime
        hour_iterator = query_date.beginning_of_day.to_datetime + 1.hours
        @wits_act_arr = Array[]

        if @wits_activity_list.first.start_time.to_datetime > date_iterator
          tmp_start_time = date_iterator
          while tmp_start_time + 1.hours < @wits_activity_list.first.start_time.to_datetime
            @wits_act_arr.push(Hash["start_time" => tmp_start_time, "end_time" => hour_iterator, "duration" => ((hour_iterator - tmp_start_time) * 24 * 3600).to_i, "activity" => "No Activity", "date" => tmp_start_time.strftime("%b %d %H:%M")])
            tmp_start_time = hour_iterator
            hour_iterator = hour_iterator + 1.hours
          end
          @wits_act_arr.push(Hash["start_time" => tmp_start_time, "end_time" => @wits_activity_list.first.start_time.to_datetime, "duration" => ((@wits_activity_list.first.start_time.to_datetime - tmp_start_time) * 24 * 3600).to_i, "activity" => "No Activity", "date" => tmp_start_time.strftime("%b %d %H:%M")])
          tmp_start_time = @wits_activity_list.first.start_time.to_datetime
        end

        last_act = nil
        @well_time_arr = {"productive_time" => 0, "invisible_time" => 0, "down_time" => 0}

        @wits_activity_list.each do |act_list|
          tmp_start_time = act_list.start_time.to_datetime

          if act_list.start_time.to_datetime < date_iterator
            tmp_start_time = date_iterator
          end

          tmp_end_time = act_list.end_time.to_datetime

          while act_list.end_time.to_datetime > hour_iterator and hour_iterator < @query_end_date
            duration = ((hour_iterator - tmp_start_time) * 24 * 3600).to_i
            @wits_act_arr.push(Hash["start_time" => tmp_start_time, "end_time" => hour_iterator, "duration" => duration, "activity" => act_list.activity_name, "depth" => act_list.bit_depth, "date" => tmp_start_time.strftime("%b %d %H:%M")])

            case act_list.activity_name
              when "Drilling Rotary", "Drilling Slide"
                @well_time_arr["productive_time"] = @well_time_arr["productive_time"] + duration

              when "Connection", "Circulating", "Run in Hole", "Run out of Hole", "Washing Upwards", "Washing Downwards", "Reaming Upwards", "Reaming Downwards"
                @well_time_arr["invisible_time"] = @well_time_arr["invisible_time"] + duration
              when "Other"
                if duration >= 300
                  @well_time_arr["down_time"] = @well_time_arr["down_time"] + duration
                else
                  @well_time_arr["invisible_time"] = @well_time_arr["invisible_time"] + duration
                end
            end

            tmp_start_time = hour_iterator
            hour_iterator = hour_iterator + 1.hours
          end

          duration = (([tmp_end_time, hour_iterator].min - tmp_start_time) * 24 * 3600).to_i
          @wits_act_arr.push(Hash["start_time" => tmp_start_time, "end_time" => [tmp_end_time, hour_iterator].min, "duration" => (([tmp_end_time, hour_iterator].min - tmp_start_time) * 24 * 3600).to_i, "activity" => act_list.activity_name, "depth" => act_list.bit_depth, "date" => tmp_start_time.strftime("%b %d %H:%M")])

          case act_list.activity_name
            when "Drilling Rotary", "Drilling Slide"
              @well_time_arr["productive_time"] = @well_time_arr["productive_time"] + duration

            when "Connection", "Circulating", "Run in Hole", "Run out of Hole", "Washing Upwards", "Washing Downwards", "Reaming Upwards", "Reaming Downwards"
              @well_time_arr["invisible_time"] = @well_time_arr["invisible_time"] + duration
            when "Other"
              if duration >= 300
                @well_time_arr["down_time"] = @well_time_arr["down_time"] + duration
              else
                @well_time_arr["invisible_time"] = @well_time_arr["invisible_time"] + duration
              end
          end

          last_act = act_list
          date_iterator = tmp_end_time
        end

        if @disp_end_date.to_datetime < last_act.end_time.to_datetime
          @wits_act_total_time = @wits_act_total_time - ((last_act.end_time.to_datetime - @disp_end_date.to_datetime) * 24 * 3600).to_i
          @wits_act_alloc[last_act.activity_name] = @wits_act_alloc[last_act.activity_name] - ((last_act.end_time.to_datetime - @disp_end_date.to_datetime) * 24 * 3600).to_i
        end

        if @disp_end_date.to_datetime > date_iterator
          tmp_start_time = date_iterator
          while tmp_start_time < @disp_end_date.to_datetime
            @wits_act_arr.push(Hash["start_time" => tmp_start_time, "end_time" => hour_iterator, "duration" => ((hour_iterator - tmp_start_time) * 24 * 3600).to_i, "activity" => "No Activity", "date" => tmp_start_time.strftime("%b %d %H:%M")])
            tmp_start_time = hour_iterator
            hour_iterator = hour_iterator + 1.hours
          end
        end

        @well_time_arr['productive_per'] = (@well_time_arr['productive_time'].to_f / (@well_time_arr['productive_time'] + @well_time_arr['invisible_time'] + @well_time_arr['down_time']).to_f * 100 * 100).to_i / 100.0
        @well_time_arr['invisible_per'] = (@well_time_arr['invisible_time'].to_f / (@well_time_arr['productive_time'] + @well_time_arr['invisible_time'] + @well_time_arr['down_time']).to_f * 100 * 100).to_i / 100.0
        @well_time_arr['down_per'] = (@well_time_arr['down_time'].to_f / (@well_time_arr['productive_time'] + @well_time_arr['invisible_time'] + @well_time_arr['down_time']).to_f * 100 * 100).to_i / 100.0

        # return Hash["total_time" => @wits_act_total_time, "well_time" => @well_time_arr, "act_arr" => @wits_act_arr, "act_alloc" => @wits_act_alloc, "start_time" => @disp_start_date, "category_histogram" => self.wits_category_histogram(query_date), "act_summary_arr" => self.activity_summary_json(@disp_start_date)]
        return Hash["total_time" => @wits_act_total_time, "well_time" => @well_time_arr, "act_arr" => @wits_act_arr, "act_alloc" => @wits_act_alloc, "start_time" => @disp_start_date, "act_summary_arr" => self.activity_summary_json(@disp_start_date)]

        # @wits_act_total_time = @wits_act_total_time - (query_date.beginning_of_day.to_datetime - @wits_activity_list.first.start_time.to_datetime) * 24 * 3600 - (@wits_activity_list.last.end_time.to_datetime - query_date.end_of_day.to_datetime) * 24 * 3600
        #debug(@wits_activity_list.first.start_time.to_datetime - query_date.beginning_of_day.to_datetime)
      else
        return Hash["total_time" => 0, "well_time" => 0, "act_arr" => [], "act_alloc" => [], "start_time" => "", "act_summary_arr" => []]
      end
    end
  end

  def wits_category_histogram_data
    wits_act_list = WitsActivityList.where(:job_id => self.id)
    total_count = wits_act_list.count
    connection_arr = []
    connection_total = 0
    bottom_arr = []
    bottom_total = 0
    treatment_arr = []
    treatment_total = 0
    wtw_arr = []
    wtw_total = 0

    wits_act_list.each_with_index do |activity, index|
      if activity['activity_name'] == "Connection" and activity['operation_time'] >= 30 and activity['operation_time'] <= 600
        connection_arr << activity
        connection_total = connection_total + activity['operation_time']
      elsif (activity['activity_name'] == "Drilling Rotary" or activity['activity_name'] == "Drilling Slide") && index > 0 && index < total_count - 1 && wits_act_list[index - 1]['activity_name'] == "Connection" && wits_act_list[index + 1]['activity_name'] == "Connection"
        bottom_arr << activity
        bottom_total = bottom_total + activity['operation_time']
      end
    end
  end

  def wits_category_histogram(start_time = '')
    Rails.cache.fetch("jobs/#{self.id}/wits_category_histogram/#{self.wits_category_lists.count}-#{self.wits_category_lists.try(:last).try(:updated_at).try(:to_s)}", expires_in: 30.days) do
      data = Hash.new
      time_break = 15 # seconds

      for iterator in 0..7
        wits_category_list = self.wits_category_lists.where(:category_name => iterator)
        next if wits_category_list.empty?

        benchmark = self.well.rig.get_benchmark_target(iterator)
        total_time = wits_category_list.sum(:operation_time).to_f
        total_count = wits_category_list.count
        average_time = (total_time / total_count).round(2)
        max_operation_time = wits_category_list.maximum(:operation_time).to_f
        ten_percent = wits_category_list.reorder("operation_time asc").limit(total_count / 10.0).select('operation_time').try(:last).try(:operation_time) || 0
        fifty_percent = wits_category_list.reorder("operation_time asc").limit(total_count / 2.0).select('operation_time').try(:last).try(:operation_time) || 0
        ninety_percent = wits_category_list.reorder("operation_time asc").limit(total_count * 9.0 / 10.0).select('operation_time').try(:last).try(:operation_time) || 0
        tmp_histo_data_arr = Array.new(max_operation_time / time_break + 2) { |e| e = 0 }
        wits_category_list.each do |category|
          tmp_histo_data_arr[(category.operation_time / time_break.to_f).ceil] += 1
        end
        histo_data_arr = Array.new
        tmp_histo_data_arr.each_with_index do |value, index|
          # if index <= 1 || tmp_histo_data_arr[index] > 0 || index == (ten_percent.to_f / time_break - 1).to_i || index == (fifty_percent.to_i / time_break - 1).to_i || index == (ninety_percent.to_i / time_break - 1).to_i
          histo_data_arr << Hash["op_time" => index * 0.25, "op_count" => value] if value > 0
          # end
        end

        wits_category_list_morning = wits_category_list.where("date_part('hour', time_stamp) >= 6 AND date_part('hour', time_stamp) < 18")
        wits_category_list_night = wits_category_list.where("date_part('hour', time_stamp) >= 18 OR date_part('hour', time_stamp) < 6")
        morning_count = wits_category_list_morning.count
        night_count = wits_category_list_night.count
        morning_crew_fifty = wits_category_list_morning.reorder("operation_time asc").limit(morning_count / 2).select('operation_time').try(:last).try(:operation_time) || 0
        night_crew_fifty = wits_category_list_night.reorder("operation_time asc").limit(night_count / 2).select('operation_time').try(:last).try(:operation_time) || 0

        result = WitsRecord.find_by_sql("
               WITH intermediate_section AS (SELECT min(entry_at) as i_start_date, max(entry_at) as i_end_date
               FROM wits_records#{self.id}
               WHERE hole_depth >= #{self.section_intermediate_start || 0} AND hole_depth < #{self.section_curve_start || 0}),
                curve_section AS (SELECT min(entry_at) as c_start_date, max(entry_at) as c_end_date
               FROM wits_records#{self.id}
               WHERE hole_depth >= #{self.section_curve_start || 0} AND hole_depth < #{self.section_tangent_start || 0}),
                lateral_section AS (SELECT min(entry_at) as l_start_date, max(entry_at) as l_end_date
               FROM wits_records#{self.id}
               WHERE hole_depth >= #{self.section_tangent_start || 0} AND hole_depth <= #{self.total_depth || 0})
                SELECT *
                FROM intermediate_section, curve_section, lateral_section;")
        intermediate_fifty = 0
        if result[0]["i_start_date"].present? && result[0]["i_end_date"].present?
          wits_category_list_i = wits_category_list.where("time_stamp >= '#{result[0]["i_start_date"]}' AND time_stamp <= '#{result[0]["i_end_date"]}'")
          intermediate_count = wits_category_list_i.count
          intermediate_fifty = wits_category_list_i.reorder("operation_time asc").limit(intermediate_count / 2).select('operation_time').try(:last).try(:operation_time) || 0
        end
        curve_fifty = 0
        if result[0]["c_start_date"].present? && result[0]["c_end_date"].present?
          wits_category_list_c = wits_category_list.where("time_stamp >= '#{result[0]["c_start_date"]}' AND time_stamp <= '#{result[0]["c_end_date"]}'")
          curve_count = wits_category_list_c.count
          curve_fifty = wits_category_list_c.reorder("operation_time asc").limit(curve_count / 2).select('operation_time').try(:last).try(:operation_time) || 0
        end
        lateral_fifty = 0
        if result[0]["l_start_date"].present? && result[0]["l_end_date"].present?
          wits_category_list_l = wits_category_list.where("time_stamp >= '#{result[0]["l_start_date"]}' AND time_stamp <= '#{result[0]["l_end_date"]}'")
          lateral_count = wits_category_list_l.count
          lateral_fifty = wits_category_list_l.reorder("operation_time asc").limit(lateral_count / 2).select('operation_time').try(:last).try(:operation_time) || 0
        end

        savings = [(total_time - total_count * benchmark), 0].max / 60.0 / 60.0 / 24.0
        potential_saving = (savings / (self.total_job_time / 60.0 / 60.0 / 24.0)) * 100

        data[iterator] = {
            "data" => histo_data_arr,
            "ten_per" => ten_percent,
            "fifty_per" => fifty_percent,
            "ninety_per" => ninety_percent,
            "morning_crew_fifty" => morning_crew_fifty,
            "night_crew_fifty" => night_crew_fifty,
            "intermediate_fifty" => intermediate_fifty,
            "curve_fifty" => curve_fifty,
            "lateral_fifty" => lateral_fifty,
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
  end


  def activity_summary(query_date)
    # search_from = Time.at(self.finished_at - 24*60*60*2)
    @tmp_act = WitsGactivity.where("job_id=? and start_time <= ?", self.id, query_date.beginning_of_day).order("start_time desc").first

    if @tmp_act.present?
      @query_start_date = WitsGactivity.where("job_id=? and start_time <= ?", self.id, query_date.beginning_of_day).order(" start_time desc").first.start_time

      if !@query_start_date.present?
        @query_start_date = query_date.beginning_of_day
      end

      @query_end_date = query_date.end_of_day
      # @wits_act_alloc = WitsActivityList.where(:job_id => self.id, :time_stamp => @query_start_date..@query_end_date).group(:activity_name).sum(:operation_time)
    else
      @query_start_date = query_date.beginning_of_day
      @query_end_date = query_date.end_of_day
    end

    logs = self.wits_gactivities.where(:start_time => @query_start_date..@query_end_date).to_a

    return logs
  end

  def activity_summary_interval(start_time, end_time)
    puts start_time
    puts end_time
    logs = self.wits_gactivities.where(:start_time => start_time..end_time).to_a

    if logs.empty?
      puts "empty"
      logs = [self.wits_gactivities.where("start_time < ?", start_time.utc.to_s).last]
    end

    puts logs

    @wits_act_arr = []
    logs.each do |log|
      puts log
      @wits_act_arr.push(Hash["start_time" => log.start_time, "end_time" => log.end_time, "duration" => (log.end_time - log.start_time).to_i, "activity" => log.activity, "depth" => log.bit_depth, "date" => log.start_time.strftime("%b %d %H:%M")])
    end
    puts @wits_act_arr

    return @wits_act_arr
  end

  def activity_summary_json(query_date)
    # search_from = Time.at(self.finished_at - 24*60*60*2)
    @tmp_act = WitsGactivity.where("job_id=? and start_time <= ?", self.id, query_date.beginning_of_day).order("start_time desc").first

    if @tmp_act.present?
      @query_start_date = WitsGactivity.where("job_id=? and start_time <= ?", self.id, query_date.beginning_of_day).order(" start_time desc").first.start_time

      if !@query_start_date.present?
        @query_start_date = query_date.beginning_of_day
      end

      @query_end_date = query_date.end_of_day
      # @wits_act_alloc = WitsActivityList.where(:job_id => self.id, :time_stamp => @query_start_date..@query_end_date).group(:activity_name).sum(:operation_time)
    else
      @query_start_date = query_date.beginning_of_day
      @query_end_date = query_date.end_of_day
    end

    logs = self.wits_gactivities.where(:start_time => @query_start_date..@query_end_date)

    return logs
  end

  def transform_activity_summary(act_logs, query_date = "")
    logs = act_logs.as_json
    non_drilling_logs = []
    new_logs = []

    logs.each_with_index do |log, index|
      if !query_date.blank? && logs[index]['start_time'] < query_date.beginning_of_day
        logs[index]['start_time'] = query_date.beginning_of_day
      end

      if !query_date.blank? && logs[index]['end_time'] > query_date.end_of_day
        logs[index]['end_time'] = query_date.end_of_day
      end
    end

    logs.each_with_index do |log, index|
      if logs[index]['activity'] != 3
        non_drilling_logs << ["log" => logs[index], "index" => index]
        act_list = WitsActivityList.where(:job_id => self.id, :end_time => logs[index]['start_time']..logs[index]['end_time'], :activity_name => ["Drilling Rotary", "Drilling Slide"]).as_json
        # act_list = WitsActivityList.where("job_id=? and activity_name in ('Drilling Rotary', 'Drilling Slide') and end_time >= ? and start_time <= ?", self.id, logs[index]['start_time'].utc.to_s, logs[index]['end_time'].utc.to_s).as_json
        puts "============" + index.to_s
        puts act_list.as_json
        gactivity = nil
        puts "======activity"
        puts self.general_activity_name_from_id(logs[index]['activity'])
        act_list.each do |activity|
          puts "=======depth_change for " + activity['activity_name']
          depth_change = self.hole_depth_next(activity['end_time']).to_f - self.hole_depth_prev(activity['start_time']).to_f

          puts depth_change
          puts activity['start_time']
          puts activity['end_time']
          if depth_change > 30.0
            gactivity = {"activity" => "3", "start_time" => activity['start_time']}
            break;
          end
        end
        puts "==========changed gactivity========="
        puts gactivity
        if !gactivity.nil?
          tmp_log = {"activity" => 3, "company_id" => logs[index]['company_id'], "created_at" => logs[index]['created_at'], "end_time" => logs[index]['end_time'], "job_id" => logs[index]['job_id'], "start_time" => gactivity['start_time'], "updated_at" => logs[index]['updated_at']}
          tmp_log['activity'] = 3
          tmp_log['start_time'] = gactivity['start_time']
          tmp_log['end_time'] = logs[index]['end_time']

          logs[index]['end_time'] = gactivity['start_time']

          if logs[index]['end_time'] == logs[index]['start_time']
            logs.delete_at(index)
          end
          new_logs << tmp_log
        end
      end
    end
    new_logs = logs + new_logs

    for i in 0..(new_logs.count - 2)
      for j in (i+1)..(new_logs.count - 1)
        if new_logs[i]['start_time'] > new_logs[j]['start_time']
          tmp = new_logs[i]
          new_logs[i] = new_logs[j]
          new_logs[j] = tmp
        end
      end
    end
    # puts "=========gc"
    # puts new_logs
    return new_logs
  end

  def activity_alloc_in_gactivity_range(gactivity)

  end

  def hole_depth_prev(query_date = "")
    query_date_string = query_date.utc.strftime("%Y-%m-%d %H:%M:%S")

    if query_date.blank?
      last_log = ActiveRecord::Base.connection.execute("select max(wits_data.hole_depth) as hole_depth from wits_data where wits_data.job_id = " + self.id).as_json
    else
      last_log = ActiveRecord::Base.connection.execute("select max(wits_data.hole_depth) as hole_depth from wits_data where wits_data.entry_at <= '" + query_date_string + "' and wits_data.job_id = " + self.id.to_s).as_json
    end

    if last_log.nil?
      return 0
    else
      puts query_date_string
      puts last_log
      return last_log[0]['hole_depth']
    end
  end

  def hole_depth_next(query_date = "")
    query_date_string = (query_date + 30.minutes).utc.strftime("%Y-%m-%d %H:%M:%S")
    if query_date.blank?
      last_log = ActiveRecord::Base.connection.execute("select max(wits_data.hole_depth) as hole_depth from wits_data where wits_data.job_id = " + self.id).as_json
    else
      last_log = ActiveRecord::Base.connection.execute("select max(wits_data.hole_depth) as hole_depth from wits_data where wits_data.entry_at <= '" + query_date_string + "' and wits_data.job_id = " + self.id.to_s).as_json
    end
    if last_log.nil?
      return 0
    else
      puts query_date_string
      puts last_log
      return last_log[0]['hole_depth']
    end
  end

  def absolute_url
    "https://www.corva.ai/jobs/" + self.id.to_s
  end

  def active
    self.status >= 1 && self.status < 50
  end

  def self.from_company(company)
    where("jobs.company_id = :company_id", company_id: company.id).order("jobs.created_at DESC")
  end

  def self.from_field(field)
    where("jobs.field_id = :field_id", field_id: field.id).order("jobs.created_at DESC")
  end

  def self.from_district(district)
    where("jobs.district_id = :district_id", district_id: district.id).order("jobs.created_at DESC")
  end

  def self.search(search, company, sort)
    terms = search.present? ? search.split : ""
    query = terms.map { |term| "lower(wells.name) like '%#{term.downcase}%'" }.join(" OR ")

    order = "jobs.start_date DESC"
    case sort
      when "name_asc"
        order = "wells.name ASC"
      when "name_desc"
        order = "wells.name DESC"
      when "ctime_asc"
        order = "jobs.start_date ASC"
    end

    return company.jobs.includes(:well).where(query).reorder(order)
  end

  def duration
    [((self.close_date.present? ? self.close_date : Date.now) - (self.start_date.present? ? self.start_date : self.created_at)).to_i / (24 * 60 * 60), 0].max
  end

  def flush_cache_status_percentage
    Rails.cache.delete([self.class.name, self.id.to_s + '-sp'])
  end

  def user_is_member?(user)
    return false if user.nil?
    job_memberships = self.job_memberships.to_a
    return job_memberships.select { |jm| jm.user_id == user.id }.any?
    #self.job_memberships.where("job_memberships.user_id = ?", user.id).any?
  end

  def closed
    return self.status == Job::COMPLETE || self.status == Job::ABANDONED
  end

  def is_job_editable?(user)
    return false if self.status == Job::COMPLETE
    return true if self.user_is_member?(user)
    return true if user.role.global_edit?
    return true if user.role.district_edit? && user.district.present? && self.district.master_district_id == user.district.master_district_id

    false
  end

  def can_user_view?(user)
    return true if user.role_id == UserRole::ROLE_FULL_ACCESS || user.role_id == UserRole::ROLE_ADMIN || (user.role_id == UserRole::ROLE_FIELD_ENGINEER && user.rig == self.rig)
    false
  end

  def begin_on_job
    self.update_attribute(:status, Job::ON_JOB)
    #self.part_memberships.each do |part_membership|
    #    if part_membership.part_type == PartMembership::INVENTORY && part_membership.part.present?
    #        part_membership.part.current_job = self
    #        part_membership.part.status = Part::ON_JOB
    #        part_membership.part.save
    #    end
    #end
  end

  def close_job(user)

    self.status = Job::COMPLETE
    self.close_date = DateTime.now
    self.save

    user.alerts.where("alerts.alert_type = :alert_type AND alerts.job_id = :job_id",
                      alert_type: Alert::POST_JOB_DATA_READY,
                      job_id: self.id).each { |a| a.destroy }

    Activity.add(user, Activity::JOB_APPROVED_TO_CLOSE, self, nil, self)

  end


  def drilling_log
    DrillingLog.joins(:job).where("jobs.well_id = ?", self.well_id).first
  end

  def well_plan
    Survey.joins(:job).where("jobs.well_id = ?", self.well_id).where(:plan => true).first
  end

  def survey
    Survey.joins(:job).where("jobs.well_id = ?", self.well_id).where(:plan => false).first
  end

  def self.include_models(jobs)
    # jobs.includes(dynamic_fields: :dynamic_field_template).includes(:field, :documents, :district).includes(:job_memberships).includes(well: :rig)
    jobs.includes(:job_memberships).includes(well: :rig)
  end

  def name
    if well.rig.present?
      "#{self.well.rig.name} - #{self.field.name} | #{self.well.name}"
    else
      "#{self.field.name} | #{self.well.name}"
    end
  end

  def well_name
    "#{self.well.name}"
    # "#{self.field.name} - #{self.well.name}"
  end

  #def update_cost
  #    costs = JobCost.job_total(self)
  #    puts costs
  #   self.update_attribute(:total_cost, costs.to_f)
  #end

  def self.cached_find(id)
    Rails.cache.fetch([name, id], expires_in: 10.minutes) { find(id) }
  end

  def flush_cache
    Rails.cache.delete([self.class.name, id])
  end

  def get_sensors
    WitsRecord.table_name = "wits_records#{self.id}"
    record = WitsRecord.find_by_sql("
                WITH depth AS (
                SELECT MAX(hole_depth) as current_hole_depth
                FROM wits_records#{self.id})
                SELECT MAX(rotary_torque) as rotary_torque, MAX(weight_on_bit) as weight_on_bit,
                    AVG(standpipe_pressure) as standpipe_pressure,
                    AVG(rotary_rpm) as rotary_rpm, AVG(hook_load) as hook_load,
                    AVG(mud_flow_in) as mud_flow_in, AVG(mud_flow_out) as mud_flow_out,
                    AVG(bit_depth) as bit_depth, AVG(hole_depth) as hole_depth, AVG(rop) as rop,
                    AVG(gain_loss) as gain_loss,
                    AVG(gamma_ray) as gamma_ray, AVG(svy_inclination) as svy_inclination, AVG(svy_azimuth) as svy_azimuth,
                    AVG(mud_volume) as mud_volume, AVG(pump_spm_1) as pump_spm_1,
                    AVG(pump_spm_2) as pump_spm_2, AVG(pump_spm_3) as pump_spm_3,
                    AVG(pit_volume_1) as pit_volume_1, AVG(pit_volume_2) as pit_volume_2,
                    AVG(pit_volume_3) as pit_volume_3, AVG(pit_volume_4) as pit_volume_4,
                    AVG(pit_volume_5) as pit_volume_5, AVG(pit_volume_6) as pit_volume_6,
                    AVG(pit_volume_7) as pit_volume_7, AVG(pit_volume_8) as pit_volume_8
                FROM wits_records#{self.id}, depth d
                WHERE hole_depth > (d.current_hole_depth - 1000) AND (state = 'DrillRot(Rotary mode drilling)' OR state = 'DrillSlide(Slide mode drilling)') AND (rotary_torque > 0 OR hook_load > 0 OR rotary_torque > 0);").first


    #result = WitsRecord.find_by_sql("
    #    SELECT max(mud_flow_in) as mud_in, max(gain_loss) as gl
    #    FROM wits_records622
    #    WHERE entry_at >= '7/12/2014 0:0:00' AND entry_at < '7/12/2014 12:50:00'
    #    ORDER BY mud_in;").to_json


    #wob_values = WitsRecord.where("state = 'DrillRot(Rotary mode drilling)'").average("weight_on_bit")


    sensors = []
    offline = 3
    large_deviation = 3
    moderate_deviation = 2
    small_deviation = 1
    good = 0
    if record != nil
      sensors << ["Torque", record.rotary_torque, (record.rotary_torque.nil? || record.rotary_torque < 0 || record.rotary_torque == 0 && record.rotary_rpm > 0) ? offline : good]
      sensors << ["Weight on Bit", record.weight_on_bit, record.weight_on_bit.nil? || record.weight_on_bit < 0 ? offline : good]
      sensors << ["Pump Pressure", record.standpipe_pressure, record.standpipe_pressure.nil? || record.standpipe_pressure <= 0 ? offline : good]
      sensors << ["RPM", record.rotary_rpm, record.rotary_rpm.nil? || record.rotary_rpm <= 0 ? offline : good]
      sensors << ["Hookload", record.hook_load, record.hook_load.nil? || record.hook_load <= 0 ? offline : good]
      sensors << ["Flow In Rate", record.mud_flow_in, record.mud_flow_in.nil? || record.mud_flow_in <= 0 ? offline : good]
      sensors << ["Flow Out Rate", record.mud_flow_out, record.mud_flow_out.nil? || record.mud_flow_out <= 0 ? offline : good]

      sensors << ["Bit Depth", record.bit_depth, record.bit_depth.nil? || record.bit_depth <= 0 ? offline : good]
      sensors << ["Hole Depth", record.hole_depth, record.hole_depth.nil? || record.hole_depth <= 0 ? offline : good]
      #sensors << ["Differential Pressure", record.diff_press.nil? || record.diff_press <= 0 ? offline : good]
      sensors << ["ROP Instantaneous", record.rop, record.rop.nil? || record.rop <= 0 ? offline : good]

      sensors << ["Gamma", record.gamma_ray, record.gamma_ray.nil? || record.gamma_ray <= 0 ? offline : good]
      sensors << ["Survey Inclination", record.svy_inclination, record.svy_inclination.nil? || record.svy_inclination <= 0 ? offline : good]
      sensors << ["Survey Azimuth", record.svy_azimuth, record.svy_azimuth.nil? || record.svy_azimuth <= 0 ? offline : good]

      sensors << ["Mud Volume", record.mud_volume, record.mud_volume.nil? || record.mud_volume <= 0 ? offline : good]
      sensors << ["Pump 1 SPM", record.pump_spm_1, record.pump_spm_1.nil? || record.pump_spm_1 < 0 || record.pump_spm_1 < 0 && record.strks_pump_1 > 0 ? offline : good]
      sensors << ["Pump 2 SPM", record.pump_spm_2, record.pump_spm_2.nil? || record.pump_spm_2 < 0 || record.pump_spm_2 < 0 && record.strks_pump_2 > 0 ? offline : good]
      sensors << ["Pump 3 SPM", record.pump_spm_3, record.pump_spm_3.nil? || record.pump_spm_3 < 0 || record.pump_spm_3 < 0 && record.strks_pump_3 > 0 ? offline : good]
      sensors << ["Gain/Loss", record.gain_loss, record.gain_loss.nil? || record.gain_loss <= 0 ? offline : good]
      sensors << ["Pit 1 Volume", record.pit_volume_1, record.pit_volume_1.nil? || record.pit_volume_1 < 0 ? offline : good]
      sensors << ["Pit 2 Volume", record.pit_volume_2, record.pit_volume_2.nil? || record.pit_volume_2 < 0 ? offline : good]
      sensors << ["Pit 3 Volume", record.pit_volume_3, record.pit_volume_3.nil? || record.pit_volume_3 < 0 ? offline : good]
      sensors << ["Pit 4 Volume", record.pit_volume_4, record.pit_volume_4.nil? || record.pit_volume_4 < 0 ? offline : good]
      sensors << ["Pit 5 Volume", record.pit_volume_5, record.pit_volume_5.nil? || record.pit_volume_5 < 0 ? offline : good]
      sensors << ["Pit 6 Volume", record.pit_volume_6, record.pit_volume_6.nil? || record.pit_volume_6 < 0 ? offline : good]
      sensors << ["Pit 7 Volume", record.pit_volume_7, record.pit_volume_7.nil? || record.pit_volume_7 < 0 ? offline : good]
      sensors << ["Pit 8 Volume", record.pit_volume_8, record.pit_volume_8.nil? || record.pit_volume_8 < 0 ? offline : good]
    end

    sensors

  end

  def get_last_hole_cleaning(date)
    WitsRecord.table_name = "wits_records#{self.id}"

    result = WitsRecord.find_by_sql("
            SELECT cuttings_transport_range, fluid_velocity, transport_ratio, cuttings_velocity, entry_at
            FROM wits_records#{self.id}
            WHERE entry_at <= '" + date.utc.to_s + "' AND cuttings_transport_range IS NOT NULL
            ORDER BY entry_at DESC
            LIMIT 1
        ")

    result.try(:first)
  end

  def get_wits_records(from, to, interval = 6)
    # Rails.cache.fetch("jobs/#{id}/wits_records/#{from.utc.to_s}-#{to.utc.to_s}-#{interval}", expires_in: 1.day, race_condition_ttl: 10) do
    WitsRecord.table_name = "wits_records#{self.id}"

    if self.time_step.present? && self.time_step != 0
      interval = (interval / self.time_step).to_i
    end

    if interval == 1
      wits_records = WitsRecord.find_by_sql("
            SELECT wits_records#{self.id}.*, row_number() OVER () AS rownum FROM wits_records#{self.id} WHERE entry_at > '" + from.utc.to_s + "' AND entry_at <= '" + to.utc.to_s + "' ORDER BY entry_at
          ")
    else
      wits_records = WitsRecord.find_by_sql("
            SELECT * FROM
            (
              SELECT wits_records#{self.id}.*, row_number() OVER () AS rownum FROM wits_records#{self.id} WHERE entry_at > '" + from.utc.to_s + "' AND entry_at <= '" + to.utc.to_s + "' ORDER BY entry_at DESC
            ) AS records
            WHERE mod(rownum,#{interval}) = 1
            ORDER BY entry_at
          ")
    end

    wits_records.as_json.collect!.with_index { |x, i| x['predicted_rop'] = x['rop'].to_f + Random.rand(50) + 5; x['predicted_rop'] = 0 if x['rop'] == 0; x['ts'] = x['entry_at'].to_time.to_i; x }
    # end
  end

  def get_driller_notes(from, to)
    from = Time.new(from.year, from.month, from.day, from.hour, from.min, from.sec).change(:offset => 5)
    to = Time.new(to.year, to.month, to.day, to.hour, to.min, to.sec).change(:offset => 5)

    ## date_part('day', entry_at) = 10
    # AND end_time < TO_DATE('#{to.in_time_zone(Time.zone).strftime('%m/%d/%Y %H:%M:%S')}', 'MM/DD/YYYY HH24:MI')
    driller_notes = DrillingLogEntry.where(:job_id => self.id).where(:additional => false).where("(entry_at, end_time) overlaps (?, ?)", from.utc, from.utc).order(:entry_at)
    driller_notes.as_json
  end

  def get_torque_rotating(date)
    date = date.utc.to_s

    WitsRecord.table_name = "wits_records#{self.id}"

    WitsRecord.where('entry_at <= ? AND drilling_hl != 0', date).order('entry_at DESC').try(:first).try(:drilling_hl)
  end

  def get_torque_slackoff(date)
    date = date.utc.to_s

    WitsRecord.table_name = "wits_records#{self.id}"

    WitsRecord.where('entry_at <= ? AND slack_off_hl != 0', date).order('entry_at DESC').try(:first).try(:slack_off_hl)
  end

  def get_torque_pickup(date)
    date = date.utc.to_s

    WitsRecord.table_name = "wits_records#{self.id}"

    WitsRecord.where('entry_at <= ? AND pick_up_hl != 0', date).order('entry_at DESC').try(:first).try(:pick_up_hl)
  end

  def get_torque_records(date, bit_depth)
    bit_depth = bit_depth || 0
    date = date.utc.to_s

    result = {}

    WitsRecord.table_name = "wits_records#{self.id}"

    open_hole_start = 5000

    # # total
    # count = WitsRecord.count(conditions: "entry_at <= '" + date + "' AND bit_depth <= " + bit_depth.to_s + " AND (slack_off_hl != 0 OR pick_up_hl != 0 OR drilling_hl != 0 OR drilling_hl_predicted != 0 OR pick_up_hl_predicted != 0 OR slack_off_hl_predicted != 0)")
    # interval = (count / 2000).floor
    # interval = [1, interval].max
    #
    # # wits_records#{self.id}.bit_depth, wits_records#{self.id}.slack_off_hl, wits_records#{self.id}.pick_up_hl, wits_records#{self.id}.drilling_hl, wits_records#{self.id}.slack_off_hl_predicted, wits_records#{self.id}.pick_up_hl_predicted, wits_records#{self.id}.drilling_hl_predicted
    # result = WitsRecord.find_by_sql("
    #       SELECT * FROM
    #       (
    #         SELECT wits_records#{self.id}.*, row_number() OVER () AS rownum FROM wits_records#{self.id} WHERE entry_at <= '" + date + "' AND bit_depth <= " + bit_depth.to_s + "  AND (slack_off_hl != 0 OR pick_up_hl != 0 OR drilling_hl != 0 OR drilling_hl_predicted != 0 OR pick_up_hl_predicted != 0 OR slack_off_hl_predicted != 0) ORDER BY bit_depth ASC
    #       ) AS records
    #       WHERE mod(rownum,#{interval}) = 0 OR rownum = #{count}
    #     ")

    #slackoff predicted
    count = WitsRecord.count(conditions: "entry_at <= '" + date + "' AND bit_depth <= #{bit_depth.to_s} AND bit_depth >= #{open_hole_start} AND slack_off_hl_predicted != 0")
    interval = (count / 40).floor
    interval = [1, interval].max

    # wits_records#{self.id}.bit_depth, wits_records#{self.id}.slack_off_hl, wits_records#{self.id}.pick_up_hl, wits_records#{self.id}.drilling_hl, wits_records#{self.id}.slack_off_hl_predicted, wits_records#{self.id}.pick_up_hl_predicted, wits_records#{self.id}.drilling_hl_predicted
    result['slackoff_predicted'] = WitsRecord.find_by_sql("
          SELECT * FROM
          (
            SELECT wits_records#{self.id}.bit_depth, wits_records#{self.id}.slack_off_hl_predicted, row_number() OVER () AS rownum FROM wits_records#{self.id} WHERE entry_at <= '" + date + "' AND bit_depth <= #{bit_depth.to_s} AND bit_depth >= #{open_hole_start} AND slack_off_hl_predicted != 0 ORDER BY bit_depth ASC
          ) AS records
          WHERE mod(rownum,#{interval}) = 0 OR rownum = #{count}
    ")

    #drilling predicted
    count = WitsRecord.count(conditions: "entry_at <= '" + date + "' AND bit_depth <= #{bit_depth.to_s} AND bit_depth >= #{5000} AND drilling_hl_predicted != 0")
    interval = (count / 40).floor
    interval = [1, interval].max

    # wits_records#{self.id}.bit_depth, wits_records#{self.id}.slack_off_hl, wits_records#{self.id}.pick_up_hl, wits_records#{self.id}.drilling_hl, wits_records#{self.id}.slack_off_hl_predicted, wits_records#{self.id}.pick_up_hl_predicted, wits_records#{self.id}.drilling_hl_predicted
    result['drilling_predicted'] = WitsRecord.find_by_sql("
          SELECT * FROM
          (
            SELECT wits_records#{self.id}.bit_depth, wits_records#{self.id}.drilling_hl_predicted, row_number() OVER () AS rownum FROM wits_records#{self.id} WHERE entry_at <= '" + date + "' AND bit_depth <= #{bit_depth.to_s} AND bit_depth >= #{open_hole_start} AND drilling_hl_predicted != 0 ORDER BY bit_depth ASC
          ) AS records
          WHERE mod(rownum,#{interval}) = 0 OR rownum = #{count}
    ")

    #pickup predicted
    count = WitsRecord.count(conditions: "entry_at <= '" + date + "' AND bit_depth <= #{bit_depth.to_s} AND bit_depth >= #{5000} AND pick_up_hl_predicted != 0")
    interval = (count / 40).floor
    interval = [1, interval].max

    # wits_records#{self.id}.bit_depth, wits_records#{self.id}.slack_off_hl, wits_records#{self.id}.pick_up_hl, wits_records#{self.id}.drilling_hl, wits_records#{self.id}.slack_off_hl_predicted, wits_records#{self.id}.pick_up_hl_predicted, wits_records#{self.id}.drilling_hl_predicted
    result['pickup_predicted'] = WitsRecord.find_by_sql("
          SELECT * FROM
          (
            SELECT wits_records#{self.id}.bit_depth, wits_records#{self.id}.pick_up_hl_predicted, row_number() OVER () AS rownum FROM wits_records#{self.id} WHERE entry_at <= '" + date + "' AND bit_depth <= #{bit_depth.to_s} AND bit_depth >= #{open_hole_start} AND pick_up_hl_predicted != 0 ORDER BY bit_depth ASC
          ) AS records
          WHERE mod(rownum,#{interval}) = 0 OR rownum = #{count}
    ")

    #pickup
    count = WitsRecord.count(conditions: "entry_at <= '" + date + "' AND bit_depth <= #{bit_depth.to_s} AND bit_depth >= #{5000} AND pick_up_hl != 0")
    interval = (count / 500).floor
    interval = [1, interval].max

    # wits_records#{self.id}.bit_depth, wits_records#{self.id}.slack_off_hl, wits_records#{self.id}.pick_up_hl, wits_records#{self.id}.drilling_hl, wits_records#{self.id}.slack_off_hl_predicted, wits_records#{self.id}.pick_up_hl_predicted, wits_records#{self.id}.drilling_hl_predicted
    result['pickup'] = WitsRecord.find_by_sql("
          SELECT * FROM
          (
            SELECT wits_records#{self.id}.bit_depth, wits_records#{self.id}.pick_up_hl, row_number() OVER () AS rownum FROM wits_records#{self.id} WHERE entry_at <= '" + date + "' AND bit_depth <= #{bit_depth.to_s} AND bit_depth >= #{open_hole_start} AND pick_up_hl != 0 ORDER BY bit_depth ASC
          ) AS records
          WHERE mod(rownum,#{interval}) = 0 OR rownum = #{count}
    ")

    #drilling
    count = WitsRecord.count(conditions: "entry_at <= '" + date + "' AND bit_depth <= " + bit_depth.to_s + " AND drilling_hl != 0")
    interval = (count / 500).floor
    interval = [1, interval].max

    # wits_records#{self.id}.bit_depth, wits_records#{self.id}.slack_off_hl, wits_records#{self.id}.pick_up_hl, wits_records#{self.id}.drilling_hl, wits_records#{self.id}.slack_off_hl_predicted, wits_records#{self.id}.pick_up_hl_predicted, wits_records#{self.id}.drilling_hl_predicted
    result['drilling'] = WitsRecord.find_by_sql("
          SELECT * FROM
          (
            SELECT wits_records#{self.id}.bit_depth, wits_records#{self.id}.drilling_hl, row_number() OVER () AS rownum FROM wits_records#{self.id} WHERE entry_at <= '" + date + "' AND bit_depth <= #{bit_depth.to_s} AND bit_depth >= #{5000} AND drilling_hl != 0 ORDER BY bit_depth ASC
          ) AS records
          WHERE mod(rownum,#{interval}) = 0 OR rownum = #{count}
    ")

    #slackoff
    count = WitsRecord.count(conditions: "entry_at <= '" + date + "' AND bit_depth <= " + bit_depth.to_s + " AND slack_off_hl != 0")
    interval = (count / 500).floor
    interval = [1, interval].max

    # wits_records#{self.id}.bit_depth, wits_records#{self.id}.slack_off_hl, wits_records#{self.id}.pick_up_hl, wits_records#{self.id}.drilling_hl, wits_records#{self.id}.slack_off_hl_predicted, wits_records#{self.id}.pick_up_hl_predicted, wits_records#{self.id}.drilling_hl_predicted
    result['slackoff'] = WitsRecord.find_by_sql("
          SELECT * FROM
          (
            SELECT wits_records#{self.id}.bit_depth, wits_records#{self.id}.slack_off_hl, row_number() OVER () AS rownum FROM wits_records#{self.id} WHERE entry_at <= '" + date + "' AND bit_depth <= #{bit_depth.to_s} AND bit_depth >= #{5000} AND slack_off_hl != 0 ORDER BY bit_depth ASC
          ) AS records
          WHERE mod(rownum,#{interval}) = 0 OR rownum = #{count}
    ")

    return result
  end

  def last_date
    last_date = wits_records.where("porepressure_emw > 0").order("entry_at desc").select(:entry_at).try(:first).try(:entry_at)
    last_date || self.start_date
  end

  def general_activity_name_from_id(id = -1)
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
      else
        return ''
    end
  end

  def activity_lists(from, to)
    Rails.cache.fetch("jobs/#{id}/activity_lists/#{from.utc.to_s}-#{to.utc.to_s}", expires_in: 1.day, race_condition_ttl: 5) do
      records = WitsActivityList.where("end_time >= '" + from.utc.to_s + "' AND start_time <= '" + to.utc.to_s + "' AND job_id = #{self.id}").order("start_time")

      agg_data = []

      records.each do |log|
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

        hash = {}
        hash['color'] = color
        hash['start_time'] = log.start_time
        hash['end_time'] = log.end_time
        hash['start_time_ts'] = log.start_time.to_time.to_i
        hash['end_time_ts'] = log.end_time.to_time.to_i
        hash['activity_name'] = log.activity_name
        hash['hole_depth'] = log.hole_depth
        hash['bit_depth'] = log.bit_depth

        agg_data << hash
      end

      return agg_data.as_json
    end
  end

  def get_gactivity(date)
    Rails.cache.fetch("jobs/#{id}/general_activity/#{date.utc.to_s}", expires_in: 1.day, race_condition_ttl: 5) do
      logs = WitsGactivity.where("start_time <= '" + date.utc.to_s + "' AND end_time >= '" + date.utc.to_s + "' AND job_id = #{self.id}")

      result = []

      logs.each do |log|
        hash = {}
        hash['gactivity_name'] = self.general_activity_name_from_id(log.activity)
        hash['hole_depth'] = log.hole_depth
        hash['bit_depth'] = log.bit_depth
        hash['start_time_ts'] = log.start_time.to_time.to_i
        hash['end_time_ts'] = log.end_time.to_time.to_i

        result << hash
      end

      return result.as_json
    end
  end

  # Total well time in seconds.
  def total_job_time
    # ---- old code ---
    # wits_category_alloc = WitsCategoryAlloc.where(:job_id => self.id).order("entry_at desc")
    # if wits_category_alloc.count > 0
    #   total = WitsCategoryAlloc.where(:job_id => self.id).order("entry_at desc").first.total_well_time
    #   return total
    # else
    #   return 0.0
    # end
    # ---- old code ---

    WitsRecord.table_name = "wits_records#{self.id}"
    first_record = WitsRecord.select("entry_at").order("entry_at ASC").try(:first)
    last_record = WitsRecord.select("entry_at").order("entry_at ASC").try(:last)
    if first_record.present? && last_record.present?
      last_record.entry_at.to_time.to_i - first_record.entry_at.to_time.to_i
    else
      0
    end
  end

  def total_days
    total_job_time / 3600.0 / 24.0
  end

  def total_job_time_by_crew(crew)
    first_date = wits_records.select("entry_at").order("entry_at ASC").try(:first).try(:entry_at)
    last_date = wits_records.select("entry_at").order("entry_at ASC").try(:last).try(:entry_at)
    return 0 if first_date.nil?
    first_day = first_date.end_of_day - first_date
    complete_days = last_date.beginning_of_day - first_date.end_of_day
    last_day = last_date - last_date.beginning_of_day
    total_time = 0
    if crew == 0
      total_time = [(first_day - 60*60*12), 0].max
      total_time += complete_days * 0.5
      total_time += [last_day, 60*60*12].min
    else
      total_time = [first_day, 60*60*12].min
      total_time += complete_days * 0.5
      total_time += [(last_day - 60*60*12), 0].max
    end
    return total_time.to_i
  end

  def get_hole_string_days
    DrillingString.where("job_id=? AND drilling_strings.default=false AND entry_at IS NOT NULL", self.id).select(:entry_at).order(:entry_at).uniq
  end

  def get_hole_string_depth
    DrillingString.find_by_sql("SELECT DISTINCT depth_from, depth_to
            FROM drilling_strings
            WHERE job_id = #{self.id} AND entry_at IS NULL
            ORDER BY depth_from;")
  end

  def has_depth_based_hole_string
    DrillingString.exists?(:entry_at => nil, :default => false, :job_id => self.id)
  end

  def has_depth_based_fluid
    Fluid.exists?(:entry_at => nil, :default => false, :job_id => self.id)
  end

  def get_hole_string(date, depth_from, depth_to)
    @result = {}

    if date.present?
      @result['drilling_strings'] = DrillingString.where(:job_id => self.id, :entry_at => date).order(:position)
      @result['casings'] = Casing.where(:job_id => self.id, :entry_at => date.utc).order('inner_diameter DESC')
      @result['bit'] = Bit.where(:job_id => self.id, :entry_at => date.utc).first
    else
      @result['drilling_strings'] = DrillingString.where(:job_id => self.id, :entry_at => date, :depth_from => depth_from, :depth_to => depth_to).order(:position)
      @result['casings'] = Casing.where('job_id=? AND entry_at IS NULL AND depth_to<=?', self.id, depth_to).order('inner_diameter DESC')
      @result['bit'] = Bit.where(:job_id => self.id, :entry_at => date, :depth_from => depth_from, :depth_to => depth_to).first
    end

    @result['hole_sizes'] = get_hole_sizes(date, depth_to)

    return @result
  end

  def open_hole_start
    casing = Casing.find_by_sql("SELECT DISTINCT inner_diameter, max(entry_at) AS entry_at, max(length) as depth
            FROM casings c
            WHERE job_id = #{self.id} AND entry_at <= TO_DATE('date.in_time_zone(Time.zone).strftime('%m/%d/%Y %H:%M:%S')', 'MM/DD/YYYY HH:MI:SS AM')
            GROUP BY inner_diameter
            ORDER BY inner_diameter ASC
            LIMIT 1")
    casing == nil ? 0 : casing[0]["depth"]
  end

  def get_fluids_days
    Fluid.where("job_id=? AND fluids.default=false AND entry_at IS NOT NULL", self.id).select(:entry_at).order(:entry_at).uniq
  end

  def get_fluids_depths
    result = Fluid.where(:job_id => self.id, :default => false, :entry_at => nil).select(:in_depth).order(:in_depth)
    return result
  end

  def add_drill_string_configuration_record(record)
    last_drill_string_date = DrillingString.where(:job_id => self.id, :default => false).where("entry_at < ?", record.entry_at).select(:entry_at).last
    if last_drill_string_date != nil
      record.compare_to_last_drill_string last_drill_string_date[:entry_at]
    else
      record.save_drill_string_record
    end
  end

  def add_fluid_configuration_record(record)
    last_fluid_date = Fluid.where(:job_id => self.id, :default => false).where("entry_at < ?", record.entry_at).select(:entry_at).last
    if last_fluid_date != nil
      record.compare_to_last_fluid last_fluid_date[:entry_at]
    else
      record.save_fluid_record
    end
  end

  def add_surveys(record)
    if record != nil
      record.surveys.each do |s|

        survey = self.survey
        if survey == nil
          survey = Survey.new
          survey.job = self
          survey.company = self.company
          survey.plan = false
          survey.save
        end

        s.transaction do
          points = SurveyPoint.where("measured_depth <= ?", s.measured_depth).order(:measured_depth).limit(2).to_a

          if points.last != nil && points.last.measured_depth == s.measured_depth
            points.last.destroy
          end


          #s = Survey.calculate_point s, points.count > 1 ? points.first : nil, survey.vertical_section_azimuth

          s.survey = survey
          s.company = self.company
          if !s.save
            puts s.errors.full_messages.join(" ") + " md #{s.measured_depth}"
          else
            puts "saved survey point #{s.measured_depth}"
          end
        end
      end
    end
  end

  def get_welbore_stabillity_data(depth=0)
    LwdLog.where('depth <= ? AND job_id = ?', depth, self.id).select("emw_pore_pressure, emw_shear_failure, emw_min_stress, emw_fracture_pressure, depth")
  end

  def get_welbore_stabillity_data1(timestamp, final_depth=15040.5)
    WitsRecord.table_name = "wits_records#{self.id}"

    if timestamp
      @witsRecord = WitsRecord.find_by_sql(" SELECT bit_depth, ecd_range FROM wits_records#{self.id} where entry_at >='" + timestamp.utc.to_s + "' order by entry_at asc limit 1").first
    else
      @witsRecord = WitsRecord.find_by_sql(" SELECT bit_depth, ecd_range FROM wits_records#{self.id} order by entry_at desc limit 1").first
    end
    if @witsRecord.nil?
      depth = 0.0
      ecd_range = [[depth, nil]]

    else
      depth = @witsRecord['bit_depth']
      ecd_range = []
      if @witsRecord['ecd_range'].nil?
        ecd_range = [[depth, nil]]
      else
        ecd_range = JSON.parse(@witsRecord['ecd_range'])
      end
    end

    mud_data = self.get_mud_window_data
    interval = final_depth / mud_data.count
    range_count = (depth / interval).to_i
    return_val = []
    for i in 0..range_count
      ecd_set = ecd_range.select { |ecd| ecd[0] >= (i * interval) }.first
      if ecd_set.present?
        return_val << [i * interval, ecd_set[1], mud_data[i][0].to_f, mud_data[i][1].to_f, mud_data[i][2].to_f, mud_data[i][3].to_f]
      end
    end
    if ecd_set.present?
      return_val << [depth, ecd_set[1], mud_data[range_count][0].to_f, mud_data[range_count][1].to_f, mud_data[range_count][2].to_f, mud_data[range_count][3].to_f]
    end

    return return_val
  end


  def get_mud_window_data
    mw = 13.0
    if $mud_data
      return $mud_data
    else
      data = []
      f = File.open("#{Rails.root}/public/mudWindowDeflection.dat", "r")

      f.each_line do |line|
        data_row = line.split(",")
        puts data_row
        for i in 0..data_row.count
          data_row[i] = mw * (1 + data_row[i].to_f)
        end
        data << data_row
      end
      $mud_data = data
      return $mud_data
    end
  end

  def current_warning
    self.event_warnings.where('closed_at IS NULL')
  end

  def warnings_order_by_depth
    self.event_warnings.reorder('depth_from ASC')
  end

  def warnings_last_for(h)
    search_from = self.closed == true ? self.end_date : self.last_date
    self.event_warnings.where('opened_at >= ?', search_from - h.hours)
  end

  def warnings_asc
    self.event_warnings.reorder('opened_at ASC')
  end

  def warnings_today
    # self.event_warnings.reorder('opened_at ASC')
    self.event_warnings.where('opened_at >= ?', Time.now.beginning_of_day.utc).reorder('opened_at ASC')
  end

  def warnings_today_desc
    # self.event_warnings.reorder('opened_at ASC')
    self.event_warnings.where('opened_at >= ?', Time.now.beginning_of_day.utc).reorder('opened_at DESC')
  end

  def warnings_yesterday
    self.event_warnings.where('opened_at >= ? AND opened_at < ?', (Time.now.beginning_of_day - 1.day).utc, Time.now.beginning_of_day.utc)
  end

  def get_time_diff
    depth_logs = self.depth_vs_time_logs
    offset_depth_logs = self.well.offset_well.job.depth_vs_time_logs
    return 0 if (depth_logs.empty? || offset_depth_logs.empty?)
    percentage = 0
    if depth_logs.length <= offset_depth_logs.length
      percentage = (depth_logs.last.to_f - offset_depth_logs[depth_logs.length - 1].to_f) / offset_depth_logs[depth_logs.length - 1].to_f * 100 unless offset_depth_logs[depth_logs.length - 1].to_f == 0
    else
      percentage = (depth_logs[offset_depth_logs.length - 1].to_f - offset_depth_logs.last.to_f) / offset_depth_logs.last.to_f * 100 unless offset_depth_logs.last.to_f == 0
    end
    return percentage
  end

  # Activity aggregate data list for last given days.
  def aggregate_activity(days)
    logs = []
    total_time = 0

    if days.to_i == -1
      logs = WitsActivityList.select("SUM(operation_time) as activity_time, activity_name").where("job_id = ?", self.id).group("activity_name")
      total_time = self.total_job_time
    else
      query_from = self.last_date.to_datetime - days.days
      logs = WitsActivityList.select("SUM(operation_time) as activity_time, activity_name").where("job_id = ? AND end_time > ?", self.id, query_from.utc.to_s).group("activity_name")
      logs.each { |log| total_time += log.activity_time.to_f }
    end

    data = []

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

      percentage = log['activity_time'].to_f / total_time * 100

      hash = {}
      hash['color'] = color
      hash['percentage'] = percentage
      hash['activity_name'] = log['activity_name']

      data << hash
    end

    return data
  end

  # Calculate maximum mse value
  def max_mse
    WitsRecord.table_name = "wits_records#{self.id}"

    record = WitsRecord.where("current_mse != 'NaN' AND current_mse != 'Infinity'").order('current_mse DESC').select('current_mse').limit(1).try(:first).try(:current_mse)
  end

  # Categorize warnings by depth
  # for ex: 1000-2000, 2000-3000, etc..
  def warnings_by_depth
    length = 1000
    result = ActiveRecord::Base.connection.execute("WITH ranges AS (
          SELECT (ten*#{length})::float AS range,
             ten*#{length} AS r_min, ten*#{length}+#{length} AS r_max
        FROM generate_series(0,(SELECT max(depth_from)/#{length} FROM event_warnings WHERE job_id=#{self.id})::int) AS t(ten))
      SELECT r.range, t.severity, count(s.*)
        FROM ranges r
        LEFT JOIN event_warnings s ON s.depth_from >= r.r_min AND s.depth_from < r.r_max
        LEFT JOIN event_warning_types t ON s.event_warning_type_id = t.warning_id
      WHERE s.job_id = #{self.id}
       GROUP BY r.range, t.severity
       ORDER BY r.range;").as_json;
    return result
  end

  # Calculate treatment graph data by depth every 250ft
  def treatment_by_depth()
    WitsRecord.table_name = "wits_records#{self.id}"

    result = WitsRecord.find_by_sql("WITH ranges AS (
          SELECT (ten*250)::float AS range,
             ten*250 AS r_min, ten*250+249 AS r_max
        FROM generate_series(0,(SELECT max(bit_depth)/250 FROM wits_records#{self.id})::int) AS t(ten))
      SELECT r.range, w.state, count(w.*)
        FROM ranges r
        LEFT JOIN wits_records#{self.id} w ON w.bit_depth >= r.r_min AND w.bit_depth < r.r_max
      WHERE w.state='PoohPumpRot(Reaming out)' OR w.state='RihPumpRot(Reaming in)' OR w.state='RihPump(Sliding in)' OR w.state='PoohPump(Sliding out)' OR w.state='Unclassified(Circulating)' OR w.state='StaticPump(Circulating)' OR w.state='StaticPumpRot(Circulating&Rot)'
       GROUP BY r.range, w.state
       ORDER BY r.range;").as_json;

    return result
  end

  def get_depth_summary(time_span = 120, step = 12)
    Rails.cache.fetch("jobs/#{id}/depth_summary/#{time_span}-#{step}-#{time_step.try(:to_i)}-#{last_date.to_time.to_i}", expires_in: 1.day, race_condition_ttl: 5) do
      interval = (time_span * 60 / (step.to_i > 0 ? step : 1) / (self.time_step.to_i > 0 ? self.time_step : 10)).to_i

      witsRecords = WitsRecord.find_by_sql("
          SELECT * FROM
          (
            SELECT wits_records#{self.id}.entry_at AS entry_at, wits_records#{self.id}.bit_depth AS bit_depth, row_number() OVER () AS rownum FROM wits_records#{self.id} ORDER BY entry_at
          ) AS records
          WHERE mod(rownum,#{interval}) = 0
        ")

      witsRecords
    end
  end

  def get_drilling_efficiency current_depth=0
    start_depth = (current_depth - 3000) <= 0 ? 0 : (current_depth - 3000)
    mid_depth = (current_depth - 300) <= 0 ? start_depth : (current_depth - 300)
    end_depth = current_depth + 3000
    result = WitsRecord.find_by_sql("WITH mse_range AS (
          SELECT current_mse
        FROM wits_records#{self.id}
        WHERE hole_depth > #{start_depth} AND hole_depth <= #{end_depth} AND bit_depth > 0 AND current_mse > 0 AND current_mse < 200000
        ORDER BY current_mse DESC
        LIMIT 200)
      	SELECT avg(w.current_mse) as avg_mse, avg(r.current_mse) as top_mse
        FROM wits_records#{self.id} w, mse_range r
        WHERE w.hole_depth > #{mid_depth} AND w.hole_depth <= #{current_depth + 300} AND w.bit_depth > 0 AND w.current_mse > 0 AND w.current_mse < 200000;")
    if result[0].top_mse.to_f == 0
      return nil
    else
      return ((result[0].top_mse.to_f - result[0].avg_mse.to_f) / result[0].top_mse.to_f) * 100.0
    end
  end

  def get_contour_data
    result = WitsRecord.find_by_sql("WITH bucketized AS (
        SELECT
           weight_on_bit,
           width_bucket(weight_on_bit, 1, 100, 100) as wob_bucket_number,
           rotary_rpm,
           width_bucket(rotary_rpm, 1, 350, 100) as rpm_bucket_number,
           rop,
           width_bucket(rop, 1, 1000, 100) as rop_bucket_number
        FROM wits_records#{self.id}
        WHERE
          state='DrillRot(Rotary mode drilling)'
        GROUP BY weight_on_bit, rotary_rpm, rop
        )
        SELECT
          ROUND(AVG(weight_on_bit))::int as average_weight_on_bit_in_group,
          wob_bucket_number,
          ROUND(AVG(rotary_rpm))::int as average_rotary_rpm_in_group,
          rpm_bucket_number,
          ROUND(AVG(rop))::int as average_rop_in_group,
          rop_bucket_number,
          COUNT(1) as distribution
        FROM bucketized
        GROUP BY
          wob_bucket_number, rpm_bucket_number, rop_bucket_number
        ORDER BY distribution DESC
        ;")

    results_array = []

    minWOB = 0
    maxWOB = 0
    minRPM = 0
    maxRPM = 0
    minROP = 0
    maxROP = 0
    wob_array = []
    rpm_array = []

    result.each do |r|
      wob = r.average_weight_on_bit_in_group.to_i
      rpm = r.average_rotary_rpm_in_group.to_i
      rop = r.average_rop_in_group.to_i

      if wob < 100 && wob > 0
        minWOB = [minWOB, wob].min
        maxWOB = [maxWOB, wob].max
        wob_array << wob
      end
      if rpm < 300 && rpm > 0
        minRPM = [minRPM, rpm].min
        maxRPM = [maxRPM, rpm].max
        rpm_array << rpm
      end
      minROP = [minROP, rop].min
      maxROP = [maxROP, rop].max

      results_array << [rpm, wob, rop]
    end


    #maxRPM = 100

    wob_mean = wob_array.mean
    rpm_mean = rpm_array.mean
    wob_sd = wob_array.standard_deviation * 3.0
    rpm_sd = rpm_array.standard_deviation * 3.0

    wob_array.delete_if { |e| e > (wob_mean + wob_sd) || e < (wob_mean - wob_sd) }
    rpm_array.delete_if { |e| e > (rpm_mean + rpm_sd) || e < (rpm_mean - rpm_sd) }

    grid = Array.new
    rpmStart = rpm_array.min
    wobStart = wob_array.min
    rpmValue = rpmStart
    wobValue = wobStart
    rpmStep = ((rpm_array.max - rpmStart) / 25.0).round
    wobStep = ((wob_array.max - wobStart) / 25.0).round
    column = 1

    puts rpmStart
    puts wobStart
    puts rpm_array.max
    puts wob_array.max
    25.times do
      grid_column = Array.new
      wobValue = wobStart
      25.times do
        grid_column << [rpmValue, wobValue, 0]
        wobValue += wobStep
      end
      grid << grid_column
      rpmValue += rpmStep
    end

    results_array.each do |a|
      rpm = [[(a[0] / rpmStep).round(0).to_i, 24].min, 0].max
      wob = [[(a[1] / wobStep).round(0).to_i, 24].min, 0].max
      rop = a[2]
      current_rop = grid[rpm][wob][2]
      if current_rop > 0
        grid[rpm][wob][2] = ((current_rop + rop) / 2.0).round
      else
        grid[rpm][wob][2] = rop
      end
    end

    return grid
  end

  def update_wellbore_sections
    job = self
    puts self.id.to_s

    start = job.section_last_entry_processed

    start = 100.years.ago
    WitsRecord.table_name = "wits_records#{job.id}"
    if start.nil?
      start = 100.years.ago
    end

    section_intermediate_start = 0
    section_curve_start = nil
    section_tangent_start = 0
    section_drop_start = 0

    last_hole_depth = 0
    last_inclination = 0
    inclination_holding = 0

    WitsRecord.where("entry_at > ?", start).order('entry_at').select('id, svy_azimuth, svy_inclination, bit_depth, hole_depth').find_each(batch_size: 2000) do |r|
      hole_depth = r[:hole_depth]
      inclination = r[:svy_inclination]
      if inclination < -900 || hole_depth < 1000
        inclination = 0
      end

      if inclination != 0 && inclination != last_inclination
        if section_curve_start.nil?
          section_curve_start = hole_depth
          puts "curve"
          puts section_curve_start
        end
      end

      if inclination != 0 && hole_depth > last_hole_depth
        inclination_holding += (hole_depth - last_hole_depth)
      end

      if section_tangent_start.nil? && inclination_holding > 100
        section_tangent_start = hole_depth
        puts "tangent"
        puts section_tangent_start
      end

      last_inclination = inclination
      last_hole_depth = hole_depth

    end

  end

  def get_vibration_data(from, to, interval)
    WitsRecord.table_name = "wits_records#{self.id}"

    interval = (interval / (self.time_step || 10)).to_i

    # TEST ONLY
    # SELECT wits_records#{self.id}.block_height as vibration_axial, wits_records#{self.id}.rotary_rpm as vibration_torsional, wits_records#{self.id}.block_height as vibration_lateral, row_number() OVER () AS rownum FROM wits_records#{self.id} WHERE entry_at >= '" + from.utc.to_s + "' AND entry_at <= '" + to.utc.to_s + "' ORDER BY entry_at

    # REAL DATA ONLY
    # SELECT wits_records#{self.id}.vibration_torsional, wits_records#{self.id}.vibration_axial, wits_records#{self.id}.vibration_lateral, row_number() OVER () AS rownum FROM wits_records#{self.id} WHERE entry_at >= '" + from.utc.to_s + "' AND entry_at <= '" + to.utc.to_s + "' ORDER BY entry_at

    @witsRecords = WitsRecord.find_by_sql("
          SELECT * FROM
          (
            SELECT wits_records#{self.id}.*, row_number() OVER () AS rownum FROM wits_records#{self.id} WHERE entry_at >= '" + from.utc.to_s + "' AND entry_at <= '" + to.utc.to_s + "' ORDER BY entry_at
          ) AS records
          WHERE mod(rownum,#{interval}) = 0
        ")

    @witsRecords.as_json
  end

  def get_bit_score current_hole_depth=0
    result = WitsRecord.find_by_sql("
        SELECT hole_depth, entry_at
        FROM wits_records#{self.id}
        WHERE bit_depth > 500 AND bit_depth < 505 AND hole_depth <= #{current_hole_depth}
        ORDER BY entry_at DESC
        LIMIT 1;")

    if result.present?
      bit_start = result.first.hole_depth
      warning = EventWarning.where("depth_from >= #{bit_start} AND job_id = #{self.id} AND event_warning_type_id > '400' AND event_warning_type_id < '450'")

      total_drilled = current_hole_depth - bit_start
      score = total_drilled / 150.0
      warning.each do |w|
        duration = (w.closed_at - w.opened_at) / 60.0 / 16.0
        case w.event_warning_type.severity
          when "low"
            score += duration
          when "moderate"
            score += duration * 1.25
          when "high"
            score += duration * 1.5
        end
      end

      return score
    else
      return 0
    end
  end


  def get_motor_score current_hole_depth=0
    result = WitsRecord.find_by_sql("
        SELECT hole_depth, entry_at
        FROM wits_records#{self.id}
        WHERE bit_depth > 500 AND bit_depth < 505 AND hole_depth <= #{current_hole_depth}
        ORDER BY entry_at DESC
        LIMIT 1;")

    if result.present?
      bit_start = result.first.hole_depth
      warning = EventWarning.where("depth_from >= #{bit_start} AND job_id = #{self.id} AND event_warning_type_id = '523'")

      total_drilled = current_hole_depth - bit_start
      score = total_drilled / 250.0
      warning.each do |w|
        duration = (w.closed_at - w.opened_at) / 60.0 / 16.0
        case w.event_warning_type.severity
          when "low"
            score += duration
          when "moderate"
            score += duration * 1.25
          when "high"
            score += duration * 1.5
        end
      end

      return score
    else
      return 0
    end
  end


  def get_time_to_depth start_depth, end_depth
    if self.section_curve_start != nil
      result = WitsRecord.find_by_sql("
               SELECT min(entry_at) as start_date, max(entry_at) as end_date
               FROM wits_records#{self.id}
               WHERE hole_depth >= #{start_depth} AND hole_depth <= #{end_depth}").try(:first)

      if !result.nil?
        (result["end_date"].to_datetime.to_f - result["start_date"].to_datetime.to_f) / (60 * 60 * 24)
      else
        0
      end
    else
      return 0
    end
  end


  def get_date_from_depth depth
    result = WitsRecord.find_by_sql("
               SELECT *
               FROM wits_records#{self.id}
               WHERE hole_depth >= #{depth}
               ORDER BY entry_at
               LIMIT 1").try(:first)

    if !result.nil?
      result['entry_at'].to_time.to_i
    else
      nil
    end
  end


  def get_section_time section
    case section.to_i
      when SECTION_VERTICAL
      when SECTION_INTERMEDIATE
        self.get_time_to_depth(self.section_intermediate_start || 0, self.section_curve_start || 0)
      when SECTION_CURVE
        self.get_time_to_depth(self.section_curve_start || 0, self.section_tangent_start || 0)
      when SECTION_TANGENT
        self.get_time_to_depth(self.section_tangent_start || 0, self.total_depth || 0)
      when SECTION_DROP
        0
      when SECTION_TOTAL
        self.get_time_to_depth(0, self.total_depth || 0)
    end
  end

  def get_section_cost section
    if self.well.present? && self.well.rig.present? && self.well.well_day_cost.present?
      days = get_section_time section
      days * self.well.well_day_cost
    end
  end

  def get_section_depth section
    case section.to_i
      when SECTION_VERTICAL
        (self.section_intermediate_start || 0) - 0
      when SECTION_INTERMEDIATE
        (self.section_curve_start || 0) - (self.section_intermediate_start || 0)
      when SECTION_CURVE
        (self.section_tangent_start || 0) - (self.section_curve_start || 0)
      when SECTION_TANGENT
        (self.total_depth.to_f || 0) - (self.section_tangent_start || 0)
      when SECTION_DROP
        0
      when SECTION_TOTAL
        self.total_depth
    end
  end

  def get_drilling_time start_depth, end_depth
    result = WitsRecord.find_by_sql("
               SELECT COUNT(*) as count, min(entry_at) as min_time, max(entry_at) as max_time
               FROM wits_records#{self.id}
               WHERE hole_depth >= #{start_depth} AND hole_depth <= #{end_depth}
                AND (state = 'DrillRot(Rotary mode drilling)' OR state = 'DrillSlide(Slide mode drilling)');")

    start_time = result[0].min_time.present? ? Time.strptime(result[0].min_time, "%Y-%m-%d %H:%M:%S").to_datetime : 0
    end_time = result[0].max_time.present? ? Time.strptime(result[0].max_time, "%Y-%m-%d %H:%M:%S").to_datetime : 0
    time_difference = end_time - start_time
    if time_difference > 0
      (time_difference.to_f * 24.0).to_f
    else
      1
    end
  end

  def drilling_time
    result = WitsRecord.find_by_sql("
               SELECT COUNT(*) as count
               FROM wits_records#{self.id}
               WHERE (state = 'DrillRot(Rotary mode drilling)' OR state = 'DrillSlide(Slide mode drilling)');")

    result[0].count.to_f * self.time_step / 60.0 / 60.0 / 24.0

    # old code
    # self.wits_category_allocs.sum('drilling_time') || 0
  end

  def section_rops
    sections = {}

    surface_drilling_time = get_drilling_time(0, self.section_intermediate_start || 0)
    intermediate_drilling_time = get_drilling_time(self.section_intermediate_start || 0, self.section_curve_start || 0)
    curve_drilling_time = get_drilling_time(self.section_curve_start || 0, self.section_tangent_start || 0)
    lateral_drilling_time = get_drilling_time(self.section_tangent_start || 0, self.total_depth || 0)


    #wits_data_arr = self.jobs.first.wits_category_allocs
    #start_log = self.jobs.first.wits_category_allocs.where("entry_at <= ?", wits_data_arr.first.entry_at).maximum(:drilling_time).to_f
    #last_log = self.jobs.first.wits_category_allocs.where("entry_at <= ?", wits_data_arr.last.entry_at).maximum(:drilling_time).to_f
    #total_time = [(last_log - start_log), 0.0].max

    #Surface
    sections[:surface] = {start_depth: 0,
                          end_depth: self.section_intermediate_start || 0,
                          md: get_section_depth(Job::SECTION_VERTICAL),
                          time: surface_drilling_time,
                          days: surface_drilling_time.to_f / 24,
                          rop: get_section_depth(Job::SECTION_VERTICAL) / surface_drilling_time}

    #Intermediate
    sections[:intermediate] = {start_depth: self.section_intermediate_start || 0,
                               end_depth: self.section_curve_start || 0,
                               md: get_section_depth(Job::SECTION_INTERMEDIATE),
                               time: intermediate_drilling_time,
                               days: intermediate_drilling_time.to_f / 24.0,
                               rop: get_section_depth(Job::SECTION_INTERMEDIATE) / intermediate_drilling_time}

    #Curve
    sections[:curve] = {start_depth: self.section_curve_start || 0,
                        end_depth: self.section_tangent_start || 0,
                        md: get_section_depth(Job::SECTION_CURVE),
                        time: curve_drilling_time,
                        days: curve_drilling_time.to_f / 24.0,
                        rop: get_section_depth(Job::SECTION_CURVE) / curve_drilling_time}

    #Lateral
    sections[:lateral] = {start_depth: self.section_tangent_start || 0,
                          end_depth: self.total_depth || 0,
                          md: get_section_depth(Job::SECTION_TANGENT),
                          time: lateral_drilling_time,
                          days: lateral_drilling_time.to_f / 24.0,
                          rop: get_section_depth(Job::SECTION_TANGENT) / lateral_drilling_time}


    return sections
  end

  def related_jobs
    related_jobs = []
    after = Job.find_by_sql("
            SELECT jobs.*
            FROM jobs
            LEFT JOIN wells on wells.id = jobs.well_id
            WHERE wells.rig_id = #{self.well.rig_id}  AND jobs.start_date > '#{self.start_date}' AND jobs.id != #{self.id}
            ORDER BY wells.rig_id, jobs.start_date DESC
            LIMIT 10")

    after.each do |j|
      related_jobs << j
    end

    before = Job.find_by_sql("
            SELECT jobs.*
            FROM jobs
            LEFT JOIN wells on wells.id = jobs.well_id
            WHERE wells.rig_id = #{self.well.rig_id}  AND jobs.start_date < '#{self.start_date}' AND jobs.id != #{self.id}
            ORDER BY wells.rig_id, jobs.start_date ASC
            LIMIT 10")

    before.each do |j|
      related_jobs << j
    end

    return related_jobs
  end

  def get_hole_sizes(date, depth_to = 0)
    if has_depth_based_hole_string
      hole_sizes = []
      bit_sizes = Bit.find_by_sql("SELECT DISTINCT size, max(depth_to) as depth
            FROM bits b
            WHERE job_id = #{self.id} AND entry_at IS NULL AND depth_to <= #{depth_to}
            GROUP BY size
            ORDER BY size DESC;")

      bit_sizes.each do |bs|
        hole_sizes << HoleSize.new(diameter: bs["size"].to_f, depth: bs["depth"].to_f)
      end
      hole_sizes
    else
      hole_sizes = []
      bit_sizes = Bit.find_by_sql("SELECT DISTINCT size, min(entry_at) AS entry_at, min(depth_from) as depth
            FROM bits b
            WHERE job_id = #{self.id} AND entry_at <= '#{date.utc.to_s}' AND entry_at IS NOT NULL
            GROUP BY size
            ORDER BY size DESC;")

      last_depth = 0
      bit_sizes.each_with_index do |bs, index|
        if bit_sizes[index + 1].present?
          hole_sizes << HoleSize.new(diameter: bs["size"].to_f, depth: bit_sizes[index + 1]["depth"].to_f)
          last_depth = bit_sizes[index + 1]["depth"].to_f
        else
          WitsRecord.table_name = "wits_records#{self.id}"
          record = WitsRecord.where("entry_at <= ?", date.utc.to_s).select('hole_depth').order('entry_at DESC').limit(1).try(:first)
          if record.present? && record['hole_depth'] > last_depth
            hole_sizes << HoleSize.new(diameter: bs["size"].to_f, depth: record['hole_depth'])
          end
        end
      end
      hole_sizes
    end
  end

  def self.open_spreadsheet(file)
    case File.extname(file.original_filename)
      when ".csv" then
        Csv.new(file.path, nil, :ignore)
      when ".xls" then
        Roo::Excel.new(file.path, nil, :ignore)
      when ".xlsx" then
        Roo::Excelx.new(file.path, nil, :ignore)
      else
        raise "Unknown file type: #{file.original_filename}"
    end
  end

  def import_bha(file)
    success = true
    xls = Job.open_spreadsheet(file)

    depth_hash = {}
    dp_header = xls.sheet(2).row(3)
    (4..xls.sheet(2).last_row).each do |i|
      row = Hash[[dp_header, xls.sheet(2).row(i)].transpose]
      depth_from = row['Start Depth'].to_f.convert_default(:ft, company_unit).round
      # depth_from = row['Start Depth'].to_f
      depth_to = row['End Depth'].to_f.convert_default(:ft, company_unit).round
      # depth_to = row['End Depth'].to_f

      depth_hash[row['BHA #']] ||= []
      depth_hash[row['BHA #']] << {
          :depth_from => depth_from,
          :depth_to => depth_to
      }

      # Save bit
      bit = Bit.new
      bit.size = row['Size'].to_f.convert_default(:in, company_unit)
      bit.make = row['Bit Make']

      nozzles = []
      nozzles = row['Nozzles'].split('/') unless row['Nozzles'].nil?
      nozzle_size = nozzles[0] ? nozzles[0].to_f.convert_default(:in, company_unit) : nil

      bit.jets = nozzles.size
      bit.nozzle_size = nozzle_size
      bit.tfa = ((nozzles.size || 1).to_f * (Math::PI / 4.0).to_f * (((nozzle_size || 0).to_f / 32.0).to_f ** 2.0).to_f).convert(:in2, company_unit)
      bit.hhsi = nil
      bit.serial_no = row['Bit Serial']
      bit.depth_from = depth_from
      bit.depth_to = depth_to
      bit.job = self

      if !bit.save
        puts ">>>>>>>>>> Error on import"
        puts bit.errors.inspect
        success = false
      end
    end

    position_hash = {}
    bha_header = xls.sheet(1).row(3)
    (4..xls.sheet(1).last_row).each do |i|
      row = Hash[[bha_header, xls.sheet(1).row(i)].transpose]

      position_hash[row['BHA #']] ||= 0

      if depth_hash[row['BHA #']].present?
        depth_hash[row['BHA #']].each do |depth|
          ds = DrillingString.new
          ds.type = row['Item Description']
          ds.outer_diameter = row['OD'].to_f.convert_default(:in, company_unit)
          ds.inner_diameter = row['ID'].to_f.convert_default(:in, company_unit)
          ds.weight = row['Mass Per Length'].to_f.convert_default(:lbm__ft, company_unit)
          # ds.weight = row['Mass Per Length'].to_f
          ds.length = row['BHA Length'].to_f.convert_default(:ft, company_unit)
          # ds.length = row['BHA Length'].to_f
          ds.depth_from = depth[:depth_from]
          ds.depth_to = depth[:depth_to]
          ds.position = position_hash[row['BHA #']]
          ds.job = self
          if !ds.save
            puts ">>>>>>>>>> Error on import"
            puts ds.errors.inspect
            success = false
          end
        end
        position_hash[row['BHA #']] += 1
      end
    end

    casing_header = xls.sheet(0).row(3)
    (4..xls.sheet(0).last_row).each do |i|
      row = Hash[[casing_header, xls.sheet(0).row(i)].transpose]

      casing = Casing.new
      casing.inner_diameter = row['String Nominal ID'].to_f.convert_default(:in, company_unit)
      casing.length = row['Length'].to_f.convert_default(:ft, company_unit)
      # casing.length = row['Length'].to_f
      casing.depth_from = 0
      casing.depth_to = row['Set Depth'].to_f.convert_default(:ft, company_unit)
      # casing.depth_to = row['Set Depth'].to_f
      casing.job = self
      if !casing.save
        puts ">>>>>>>>>> Error on import"
        puts casing.errors.inspect
        success = false
      end
    end

    mud_header = xls.sheet(3).row(3)
    (4..xls.sheet(3).last_row).each do |i|
      row = Hash[[mud_header, xls.sheet(3).row(i)].transpose]

      mud = Fluid.new
      mud['density'] = row['Density'].to_f.convert_default(:ppg, company_unit)
      # mud['density'] = row['Density'].to_f
      mud['funnel_viscosity'] = row['Funnel Viscosity']
      mud['pv'] = row['PV'].to_f.convert_default(:cp, company_unit)
      mud['yp'] = row['YP'].to_f.convert_default(:lbf__100_ft2, company_unit)
      mud['rpm3'] = row['Vis 3rpm']
      mud['rpm6'] = row['Vis 6rpm']
      mud['rpm100'] = row['Vis 100rpm']
      mud['rpm200'] = row['Vis 200rpm']
      mud['rpm300'] = row['Vis 300rpm']
      mud['rpm600'] = row['Vis 600rpm']
      mud['in_depth'] = row['Depth'].to_f.convert_default(:ft, company_unit).round
      mud.job = self
      if !mud.save
        puts ">>>>>>>>>> Error on import"
        puts mud.errors.inspect
        success = false
      end
    end

    return success
  end

  def import_survey(file)
    success = true
    xls = Job.open_spreadsheet(file)

    # Create new survey
    survey = self.survey
    if survey.nil?
      survey = Survey.new
      survey.job = self
      survey.company = self.company
      survey.plan = false
      if !survey.save
        puts survey.errors.inspect
      end
    end

    SurveyPoint.where(:survey_id => survey.id).destroy_all

    header = xls.sheet(0).row(1)
    (2..xls.sheet(0).last_row).each do |i|
      row = Hash[[header, xls.sheet(0).row(i)].transpose]

      # Save survey point
      survey_point = SurveyPoint.new
      survey_point.measured_depth = row['MD'].to_f.convert_default(:ft, company_unit)
      # survey_point.measured_depth = row['MD'].to_f
      survey_point.inclination = row['Inc']
      survey_point.azimuth = row['Azimuth']
      survey_point.survey = survey
      survey_point.company = self.company

      if !survey_point.save
        puts ">>>>>>>>>> Error on import"
        puts survey_point.errors.inspect
        success = false
      end
    end

    return success
  end

  def clean_job
    current_job = self
    @url = URI.parse(CorvaUrlCONFIG['corva_data_java_uri'] + '/clean_redis.xml')

    requestXml = {:job_id => current_job.id.to_s}.to_json
    http = Net::HTTP.new(@url.host, @url.port)
    http.read_timeout = 1000000
    request = Net::HTTP::Post.new(@url.path)
    request.body = requestXml
    request["Content-Type"] = "application/xml"
    response = http.request(request)


    table_name = "wits_records#{current_job.id}"
    if WitsRecord.connection.table_exists? table_name
      WitsRecord.connection.execute("drop table wits_records#{current_job.id}")
    end
    ActiveRecord::Base.connection.execute("delete from wits_activity_lists where job_id = " + current_job.id.to_s)
    ActiveRecord::Base.connection.execute("delete from wits_category_allocs where job_id = " + current_job.id.to_s)
    ActiveRecord::Base.connection.execute("delete from wits_category_lists where job_id = " + current_job.id.to_s)
    ActiveRecord::Base.connection.execute("delete from wits_data where job_id = " + current_job.id.to_s)
    ActiveRecord::Base.connection.execute("delete from wits_gactivities where job_id = " + current_job.id.to_s)
    ActiveRecord::Base.connection.execute("delete from drilling_logs where job_id = " + current_job.id.to_s)
    ActiveRecord::Base.connection.execute("delete from programs_wells where well_id = " + current_job.well.id.to_s)
    ActiveRecord::Base.connection.execute("delete from event_warnings where job_id = " + current_job.id.to_s)


    # _logger( 'd', "AWS deleting" )
    # s3 = AWS::S3.new
    #
    # bucket = s3.buckets[AWSConfig['BUCKET'] + '/job' + current_job.id.to_s]
    # torque_drag_data = TorqueDragData.where(:job_id => current_job.id).to_a
    # torque_drag_data.each do |data_row|
    #   object = bucket.objects[data_row['file_name']]
    #   # TorqueDragData.delete(data_row['id'])
    #   object.delete
    # end
    ActiveRecord::Base.connection.execute("delete from torque_drag_data where job_id = " + current_job.id.to_s)
    ActiveRecord::Base.connection.execute("delete from torque_drag_charts where job_id = " + current_job.id.to_s)
    # _logger( 'd', "AWS deleted" )
  end

  def merge_warnings
    # Rails.cache.fetch(cache_key_for_warnings, expires_in: 30.days, race_condition_ttl: 10) do
    temp_warning = {}
    hole_cleaning = nil
    hole_cleaning_duration = {}

    warnings_asc.each do |warning|
      if warning.event_warning_type.category.to_i == CompanyFeature::TORQUE_AND_DRAG
        if temp_warning[warning.event_warning_type.warning_id].present? && temp_warning[warning.event_warning_type.warning_id].depth_to + 100 >= warning.depth_from
          temp_warning[warning.event_warning_type.warning_id].closed_at = warning.closed_at
          temp_warning[warning.event_warning_type.warning_id].depth_to = warning.depth_to
          warning.delete
        else
          temp_warning[warning.event_warning_type.warning_id].save if temp_warning[warning.event_warning_type.warning_id].present?
          temp_warning[warning.event_warning_type.warning_id] = warning
        end
      elsif warning.event_warning_type.category.to_i == CompanyFeature::HOLE_CLEANING
        hole_cleaning_duration[warning.event_warning_type.severity] = (hole_cleaning_duration[warning.event_warning_type.severity] || 0) + warning.closed_at.to_time.to_i - warning.opened_at.to_time.to_i
        if hole_cleaning.present? && hole_cleaning.depth_to + 100 >= warning.depth_from
          hole_cleaning.closed_at = warning.closed_at
          hole_cleaning.depth_to = warning.depth_to
          warning.delete
        else
          if hole_cleaning.present?
            if hole_cleaning_duration['high'].present? && hole_cleaning_duration['moderate'].present?
              hole_cleaning.event_warning_type_id = '313' if hole_cleaning_duration['high'] > hole_cleaning_duration['moderate']
              hole_cleaning.event_warning_type_id = '311' unless hole_cleaning_duration['high'] > hole_cleaning_duration['moderate']
            end
            hole_cleaning.save
          end
          hole_cleaning = warning
        end
      end
    end

    temp_warning.each do |key, value|
      value.save if value.present?
    end

    if hole_cleaning.present?
      if hole_cleaning_duration['high'].present? && hole_cleaning_duration['moderate'].present?
        hole_cleaning.event_warning_type_id = '313' if hole_cleaning_duration['high'] > hole_cleaning_duration['moderate']
        hole_cleaning.event_warning_type_id = '311' unless hole_cleaning_duration['high'] > hole_cleaning_duration['moderate']
      end
      hole_cleaning.save
    end
    # end
  end

  def cache_key_for_warnings
    count = event_warnings.count
    max_updated_at = EventWarning.max_updated_at_by_job(id)
    "jobs/#{id}/warnings/#{count}-#{max_updated_at}"
  end

  def get_out_of_hole_date_summary
    wits_activity_lists.where("bit_depth < 500").select("start_time, end_time, operation_time")
  end

  def company_unit
    self.company.company_unit_str
  end

  def total_depth(crew= -1)
    if crew == 0
      start_date = self.wits_data.first.entry_at
      last_date = self.wits_data.last.entry_at

      query_start_date = [start_date, (start_date.beginning_of_day + 6.hours)].max
      if query_start_date < start_date.beginning_of_day + 18.hours
        query_end_date = start_date.beginning_of_day + 18.hours
      else
        query_start_date = [query_start_date, start_date.beginning_of_day + 6.hours + 24.hours].max
        query_end_date = start_date.beginning_of_day + 18.hours + 24.hours
      end
      while (query_start_date < last_date)
        start_log = self.wits_data.where("entry_at <= ?", query_start_date).last
        last_log = self.wits_data.where("entry_at <= ?", query_end_date).last
        total_depth = total_depth + [(last_log.nil? ? "0.0" : last_log.hole_depth) - (start_log.nil? ? "0.0" : start_log.hole_depth), 0].max
        query_start_date = query_end_date + 12.hours
        query_end_date = query_end_date + 24.hours
      end
      return total_depth
    elsif crew == 1
      start_date = self.wits_data.first.entry_at
      last_date = self.wits_data.last.entry_at

      query_start_date = start_date.beginning_of_day + 6.hours
      if start_date < query_start_date
        query_end_date = query_start_date
        query_start_date = start_date
      else
        query_start_date = [start_date, (start_date.beginning_of_day + 18.hours)].max
        query_end_date = start_date.beginning_of_day + 30.hours
      end
      while (query_start_date < last_date)
        start_log = self.wits_data.where("entry_at <= ?", query_start_date).last
        last_log = self.wits_data.where("entry_at <= ?", query_end_date).last
        total_depth = total_depth + [(last_log.nil? ? "0.0" : last_log.hole_depth) - (start_log.nil? ? "0.0" : start_log.hole_depth), 0].max
        query_start_date = query_end_date + 12.hours
        query_end_date = query_end_date + 24.hours
      end
      return total_depth
    elsif crew == -1
      self.wits_data.maximum("hole_depth") || 0
    end
  end

  # def total_depth_by_crew(crew)
  #   total_depth = 0
  #   if crew == 0
  #     start_date = self.wits_data.first.entry_at
  #     last_date = self.wits_data.last.entry_at
  #
  #     query_start_date = [start_date, (start_date.beginning_of_day + 6.hours)].max
  #     if query_start_date < start_date.beginning_of_day + 18.hours
  #       query_end_date = start_date.beginning_of_day + 18.hours
  #     else
  #       query_start_date = [query_start_date, start_date.beginning_of_day + 6.hours + 24.hours].max
  #       query_end_date = start_date.beginning_of_day + 18.hours + 24.hours
  #     end
  #     while (query_start_date < last_date)
  #       start_log = self.wits_data.where("entry_at <= ?", query_start_date).last
  #       last_log = self.wits_data.where("entry_at <= ?", query_end_date).last
  #       total_depth = total_depth + [(last_log.nil? ? "0.0" : last_log.hole_depth) - (start_log.nil? ? "0.0" : start_log.hole_depth), 0].max
  #       query_start_date = query_end_date + 12.hours
  #       query_end_date = query_end_date + 24.hours
  #     end
  #     return total_depth
  #   elsif crew == 1
  #     start_date = self.wits_data.first.entry_at
  #     last_date = self.wits_data.last.entry_at
  #
  #     query_start_date = start_date.beginning_of_day + 6.hours
  #     if start_date < query_start_date
  #       query_end_date = query_start_date
  #       query_start_date = start_date
  #     else
  #       query_start_date = [start_date, (start_date.beginning_of_day + 18.hours)].max
  #       query_end_date = start_date.beginning_of_day + 30.hours
  #     end
  #     while (query_start_date < last_date)
  #       start_log = self.wits_data.where("entry_at <= ?", query_start_date).last
  #       last_log = self.wits_data.where("entry_at <= ?", query_end_date).last
  #       total_depth = total_depth + [(last_log.nil? ? "0.0" : last_log.hole_depth) - (start_log.nil? ? "0.0" : start_log.hole_depth), 0].max
  #       query_start_date = query_end_date + 12.hours
  #       query_end_date = query_end_date + 24.hours
  #     end
  #     return total_depth
  #   end
  # end

  def rop(crew = -1)
    if crew == -1
      total_depth.to_f / ((total_job_time.to_f.nonzero? || 1) / 3600.0)
    else
      total_depth(crew).to_f / ((total_job_time(crew).to_f.nonzero? || 1) / 3600.0)
    end
  end

  # def rop_by_crew(crew)
  #   self.total_depth_by_crew(crew).to_f / (self.total_job_time_by_crew(crew).to_f.nonzero? || 1) * 3600
  # end

  def drilling_rop(crew = -1)
    total_depth.to_f / (drilling_time.to_f.nonzero? || 1) / 24.0
  end

  def potential_savings(crew = -1)
    if crew == -1
      savings = WitsCategoryList.find_by_sql("select wits_category_lists.category_name as category_id,
          sum(wits_category_lists.operation_time) as duration,
          count(wits_category_lists.time_index) as operation_count
        from wits_category_lists
        where job_id=" + self.id.to_s + "
        group by wits_category_lists.category_name")
      savings_sum = 0
      savings.each do |saving|
        savings_sum = savings_sum + saving.duration.to_f - saving.operation_count.to_i * self.well.rig.get_benchmark_target(saving.category_id).to_f
      end
      return savings_sum / (self.total_job_time.to_f.nonzero? || 1)
    elsif crew == 0
      savings = WitsCategoryList.find_by_sql("select wits_category_lists.category_name as category_id,
          sum(wits_category_lists.operation_time) as duration,
          count(wits_category_lists.time_index) as operation_count
        from wits_category_lists
        where wits_category_lists.job_id = #{self.id} and
          (\"time\"(wits_category_lists.time_stamp)) > '06:00:00' and
          (\"time\"(wits_category_lists.time_stamp)) <= '18:00:00'
        group by wits_category_lists.category_name")
      savings_sum = 0
      savings.each do |saving|
        savings_sum = savings_sum + saving.duration.to_f - saving.operation_count.to_i * self.well.rig.get_benchmark_target(saving.category_id).to_f
      end
      return savings_sum / self.total_job_time.to_f
    elsif crew == 1
      savings = WitsCategoryList.find_by_sql("select wits_category_lists.category_name as category_id,
          sum(wits_category_lists.operation_time) as duration,
          count(wits_category_lists.time_index) as operation_count
        from wits_category_lists
        where wits_category_lists.job_id=#{self.id} and
          (((\"time\"(wits_category_lists.time_stamp)) >= '00:00:00' and (\"time\"(wits_category_lists.time_stamp)) <= '06:00:00') or ((\"time\"(wits_category_lists.time_stamp)) > '18:00:00' and (\"time\"(wits_category_lists.time_stamp)) <= '23:59:59'))
        group by wits_category_lists.category_name")
      savings_sum = 0
      savings.each do |saving|
        savings_sum = savings_sum + saving.duration.to_f - saving.operation_count.to_i * self.well.rig.get_benchmark_target(saving.category_id).to_f
      end
      return savings_sum / self.total_job_time.to_f
    end
  end

  # def potential_savings_by_crew(crew)
  #   if crew == 0
  #     savings = WitsCategoryList.find_by_sql("select wits_category_lists.category_name as category_id,
  #         sum(wits_category_lists.operation_time) as duration,
  #         count(wits_category_lists.time_index) as operation_count
  #       from wits_category_lists
  #       where wits_category_lists.job_id = #{self.id} and
  #         (\"time\"(wits_category_lists.time_stamp)) > '06:00:00' and
  #         (\"time\"(wits_category_lists.time_stamp)) <= '18:00:00'
  #       group by wits_category_lists.category_name")
  #     savings_sum = 0
  #     savings.each do |saving|
  #       savings_sum = savings_sum + saving.duration.to_f - saving.operation_count.to_i * self.well.rig.get_benchmark_target(saving.category_id).to_f
  #     end
  #     return savings_sum / self.total_job_time.to_f
  #   elsif crew == 1
  #     savings = WitsCategoryList.find_by_sql("select wits_category_lists.category_name as category_id,
  #         sum(wits_category_lists.operation_time) as duration,
  #         count(wits_category_lists.time_index) as operation_count
  #       from wits_category_lists
  #       where wits_category_lists.job_id=#{self.id} and
  #         (((\"time\"(wits_category_lists.time_stamp)) >= '00:00:00' and (\"time\"(wits_category_lists.time_stamp)) <= '06:00:00') or ((\"time\"(wits_category_lists.time_stamp)) > '18:00:00' and (\"time\"(wits_category_lists.time_stamp)) <= '23:59:59'))
  #       group by wits_category_lists.category_name")
  #     savings_sum = 0
  #     savings.each do |saving|
  #       savings_sum = savings_sum + saving.duration.to_f - saving.operation_count.to_i * self.well.rig.get_benchmark_target(saving.category_id).to_f
  #     end
  #     return savings_sum / self.total_job_time.to_f
  #   end
  # end

  def depth_vs_time_logs
    started_at = self.start_date.to_i
    results = []
    last_depth = 0
    for i in 0..(self.total_job_time/24/3600).round
      time_axis_from = started_at + (i-1)*24*60*60
      time_axis_to = started_at + i*24*60*60
      logs = WitsData.find_by_sql("select wits_data.hole_depth as depth from wits_data where job_id = " + self.id.to_s + " and entry_at > '" + Time.at(time_axis_from).utc.to_s + "' and wits_data.entry_at < '" + Time.at(time_axis_to).utc.to_s + "'")
      if logs.empty?
        results<<last_depth
      else
        sum = 0
        max_depth = 0
        logs.each do |log|
          depth = log.depth.to_f
          sum += depth
          if depth > max_depth
            max_depth = depth
          end
        end
        avg_depth = sum / logs.length
        if max_depth - avg_depth > 5000
          last_depth = avg_depth
          results<<avg_depth
        else
          last_depth = max_depth
          results<<max_depth
        end
      end
    end
    return results
  end

  def depth_vs_cost_logs
    day_cost = self.well.well_day_cost
    return [] if day_cost == 0
    logs = []
    tick = 50000 # cost
    x_axis = (self.total_job_time / 24 / 3600 * day_cost / tick).ceil
    for i in 0..x_axis
      time_at = self.start_date.to_i + 24 * 60 * 60 * i * tick / day_cost
      time_at = [time_at, self.last_date.to_i].min
      depth = self.wits_data.select('hole_depth').where('entry_at < ?', Time.at(time_at.round).utc.to_s).reorder('hole_depth DESC').limit(1).try(:first).try(:hole_depth)
      logs << [((time_at - start_date.to_i) / 24 / 3600 * day_cost).round, (depth || 0)]
    end
    return logs
  end

  def depth_vs_warnings_logs
    logs = []
    tick = 100 # depth
    x_axis = (total_depth / tick).ceil
    for i in 0..x_axis
      depth_at = [i * tick, total_depth].min
      warnings = self.event_warnings.where('depth_from <= ?', depth_at).count
      logs << [warnings, depth_at]
    end
    return logs
  end

  def footage_logs
    logs = self.depth_vs_time_logs
    # for i in 1..(logs.count - 1)
    #   if logs[i] < logs[i - 1]
    #     logs[i] = logs[i - 1]
    #   end
    # end
    for i in (logs.count - 1).downto(1)
      logs[i] = [(logs[i] - logs[i - 1]), 0].max
    end
    return logs
  end

  def total_cost
    total_job_time / 3600 / 24 * self.well.well_day_cost
  end

  def current_activity
    self.wits_activity_lists.select('activity_name').reorder('start_time DESC').limit(1).try(:first).try(:activity_name) || ''
  end

  def current_gactivity
    gactivity_id = self.wits_gactivities.select('activity').reorder('start_time DESC').limit(1).try(:first).try(:activity)
    self.general_activity_name_from_id(gactivity_id)
  end

  def current_bit_depth
    self.wits_data.select('bit_depth').reorder('entry_at DESC').limit(1).try(:first).try(:bit_depth) || 0
  end

  def current_category
    category_id = self.wits_category_lists.select('category_name').reorder('time_stamp DESC').limit(1).try(:first).try(:category_name)
    category_name_from_id(category_id) || ''
  end

  def get_torque_chart(date)
    result = {}
    s3 = AWS::S3.new
    bucket = s3.buckets[AWSConfig['BUCKET'] + '/job' + self.id.to_s]

    torque_data = TorqueDragData.where("job_id = ? and entry_at <= ?", self.id, date.utc).order("entry_at desc").limit(1).try(:first)
    puts torque_data.inspect
    if torque_data.present?
      result['broomstick'] = read_json_from_s3(bucket, torque_data['file_name'])
      result['ff'] = read_json_from_s3(bucket, torque_data['file_name'].to_s + '_FF')
    end

    torque_chart = TorqueDragChart.where("job_id = ? and entry_at <= ?", self.id, date.utc).order("entry_at desc").limit(1).try(:first)
    if torque_chart.present?
      result['other'] = read_json_from_s3(bucket, torque_chart['file_name'])
    end

    return result
  end

  def warning_hashes
    result = [];

    self.warnings_asc.each do |warning|
      w = {}
      w['id'] = warning.id
      w['name'] = warning.name
      w['opened_at'] = warning.opened_at.to_time.to_i
      w['closed_at'] = warning.closed_at.present? ? warning.closed_at.to_time.to_i : 0
      w['family'] = warning.event_warning_type.category
      w['tray_name'] = warning.tray_name
      w['short_resolution'] = warning.short_resolution
      w['severity'] = warning.event_warning_type.severity
      w['duration'] = warning.duration
      w['activity_name'] = warning.activity_name
      w['depth_from'] = warning.depth_from.to_f
      w['depth_to'] = warning.closed_at.present? ? warning.depth_to.to_f : ''
      w['resolution'] = warning.resolution
      w['opened_at_str'] = warning.opened_at.strftime("%b %e, %Y %k:%M")
      w['type'] = warning.event_warning_type_id
      w['info'] = JSON.parse(warning.info || "{}")
      result << w
    end

    result
  end

  def warning_entities
    result = [];

    self.warnings_asc.each do |warning|
      w = {}
      w['entity_type'] = 0
      w['id'] = warning.id
      w['name'] = warning.name
      w['opened_at'] = warning.opened_at.to_time.to_i
      w['closed_at'] = warning.closed_at.present? ? warning.closed_at.to_time.to_i : 0
      w['family'] = warning.event_warning_type.category
      w['tray_name'] = warning.tray_name
      w['short_resolution'] = warning.short_resolution
      w['severity'] = warning.event_warning_type.severity
      w['duration'] = warning.duration
      w['activity_name'] = warning.activity_name
      w['depth_from'] = warning.depth_from.to_f
      w['depth_to'] = warning.closed_at.present? ? warning.depth_to.to_f : ''
      w['resolution'] = warning.resolution
      w['opened_at_str'] = warning.opened_at.strftime("%b %e, %Y %k:%M")
      w['type'] = warning.event_warning_type_id
      w['info'] = JSON.parse(warning.info || "{}")
      result << w
    end

    self.annotations.includes(:annotation_comments).each do |annotation|
      a = {}
      a['entity_type'] = 1
      a['id'] = annotation.id
      a['name'] = annotation.title
      a['description'] = annotation.annotation_comments.any? ? annotation.annotation_comments.first.text : ''
      a['opened_at'] = annotation.start_time.to_time.to_i
      a['depth_from'] = annotation.start_depth.to_f
      a['family'] = 'annotations'
      result << a
    end

    result
  end

  def warning_entities_order_by_depth
    warning_entities.sort_by { |w| w['depth_from'] }
  end

  def warning_entities_order_by_date
    warning_entities.sort_by { |w| w['opened_at'] }
  end

  def self.create_job well_name, rig_name, company
    Job.transaction do
      rig = Rig.where(:company_id => company.id).where("rigs.name = ?", rig_name).limit(1).first
      if !rig.present?
        puts "Rig Not Present"
        rig = nil
        rig = Rig.new
        rig.company = company
        rig.name = rig_name

        if !rig.save
          message = "Rig Error!"
          raise ActiveRecord::Rollback
          return
        end
      else
        puts "Rig Present"
      end

      well = Well.where(:company_id => company.id).where("wells.name = ?", well_name).limit(1).first
      job = nil
      if !well.present?
        puts "Well Not Present"
        well = nil
        well = Well.new
        well.field = company.fields.first
        well.name = well_name
        well.company = company
        well.programs = [rig.program] if !rig.program.nil?
        well.rig = rig
        if rig.offset_well.present?
          well.offset_well = @rig.offset_well
        end
        if well.programs.empty?
          if rig.program.present?
            well.programs << rig.program
          end
        end

        if !well.save
          puts well_name
          puts well.errors.full_messages
          raise ActiveRecord::Rollback
          return
        end
        job = Job.new
        job.district = company.districts.first
        job.company = company
        job.well = well
        job.field = company.fields.first
      else
        puts "Well Present"
        job = well.jobs.first
        job.clean_job
      end


      job.status = Job::ON_JOB
      job.time_step = 10

      if job.save
        puts "Job Saved #{job.id}"
      else
        puts job.errors.full_messages
        raise ActiveRecord::Rollback
        return nil
      end

      if job.id.present?
        table_name = "wits_records#{job.id}"
        if !(WitsRecord.connection.table_exists? table_name)
          WitsRecord.connection.execute("CREATE TABLE #{table_name} (LIKE wits_records INCLUDING DEFAULTS INCLUDING INDEXES)")
        end

        return job
      end
    end

    return nil
  end


  private


  def wits_records
    WitsRecord.table_name = "wits_records#{self.id}"
    WitsRecord
  end

  def read_json_from_s3(bucket, file_name)
    object = bucket.objects[file_name]
    json_str= object.read.to_s.gsub('\\', '')
    json_str[1..(json_str.length-2)]
  rescue
    ""
  end
end

