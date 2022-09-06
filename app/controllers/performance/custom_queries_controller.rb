class Performance::CustomQueriesController < Performance::ModuleController
  before_filter :set_custom_queries_tab

  def index
    @wells ||= Well.completed

    params.each do |key, value|
        case key
            when "md"
                values = value.gsub('[', '').gsub(']', '').gsub(',', '').split("-")
                @wells = @wells.where("wells.hole_depth >= ? AND wells.hole_depth <= ?", values[0].to_f.convert_default(:ft, company_unit), values[1].to_f.convert_default(:ft, company_unit))
            when "time"
                values = value.gsub('[', '').gsub(']', '').gsub(',', '').split("-")
                @wells = @wells.where("wells.total_time >= ? AND wells.total_time <= ?", values[0].to_f * 3600.0 * 24.0, values[1].to_f * 3600.0 * 24.0)
            when "start"
                values = value.gsub('[', '').gsub(']', '').gsub(',', '').split("-")
                @wells = @wells.where("wells.started_at >= ? AND wells.started_at <= ?", Date.strptime(values[0].split(' ')[0], "%m/%d/%Y"), Date.strptime(values[1].split(' ')[0], "%m/%d/%Y"))
            when "rig"
                value = value.gsub('[', '').gsub(']', '')
                @wells = @wells.includes(:rig).where("rigs.name = ?", value)
            when "county"
                value = value.gsub('[', '').gsub(']', '')
                @wells = @wells.where("wells.county = ?", value)
            when "field"
                value = value.gsub('[', '').gsub(']', '')
                @wells = @wells.where("wells.field = ?", value)
            when "dc"
                value = value.gsub('[', '').gsub(']', '')
                @wells = @wells.where("wells.drilling_company = ?", value)
            when "fc"
                value = value.gsub('[', '').gsub(']', '')
                @wells = @wells.where("wells.fluid_company = ?", value)

            when "warning_depth"
                values = value.gsub('[', '').gsub(']', '').gsub(',', '').split("-")
                @wells = @wells.includes(jobs: :event_warnings).where("event_warnings.depth_from >= ? AND event_warnings.depth_to <= ?", values[0].to_f.convert_default(:ft, company_unit), values[1].to_f.convert_default(:ft, company_unit))

            when "rop"
                values = value.gsub('[', '').gsub(']', '').gsub(',', '').split("-")
                @wells = @wells.where("wells.drilling_rop >= ? AND wells.drilling_rop <= ?", values[0].to_f.convert_default(:ft, company_unit), values[1].to_f.convert_default(:ft, company_unit))


            when "bit_size"
                value = value.gsub('[', '').gsub(']', '')
                @wells = @wells.includes(jobs: :bit).where("bits.size = ?", value.to_f.convert_default(:in, company_unit))
            when "bit_make"
                value = value.gsub('[', '').gsub(']', '')
                @wells = @wells.includes(jobs: :bit).where("bits.make = ?", value)
            when "bit_serial"
                value = value.gsub('[', '').gsub(']', '')
                @wells = @wells.includes(jobs: :bit).where("bits.serial = ?", value)

            when "casing_size"
                value = value.gsub('[', '').gsub(']', '')
                @wells = @wells.includes(jobs: :casing).where("casings.inner_diameter = ?", value.to_f.convert_default(:in, company_unit))
            when "casing_depth"
                value = value.gsub('[', '').gsub(']', '')
                @wells = @wells.includes(jobs: :casing).where("casings.depth_to >= ?", value.to_f.convert(:ft, company_unit))
        end
    end

    params.each do |key, value|
        EventWarningType.all.each do |ew|
            if "ew#{ew.warning_id}" == key
                @wells = @wells.includes(jobs: :event_warnings).where("event_warnings.event_warning_type_id = ?", ew.warning_id)
            end
        end
    end

    @well_id = []
    @well_id = params[:id].delete(' ').split(',') if params[:id].present?
    @history_id = params[:history] || -1
  end

  def get_histogram
    if !valid_histogram_param
      render json: {errors: 'Invalid parameters'}, status: 400 and return
    end

    if params['rig_id'].to_i == -1
      rigs = Rig.includes(:wells)
    else
      rigs = Rig.where(id: params['rig_id'])
    end

    wits_category_histogram = Hash.new
    rigs.each do |rig|
      wits_category_histogram[rig.id] = rig.rig_wits_category_histogram(params['history_id'])
    end

    render json: wits_category_histogram.to_json
  end

  private

  def valid_histogram_param
    params[:well_id] && params[:history_id]
  end

  def set_custom_queries_tab
    @active_tab = 'custom_queries'
  end
end