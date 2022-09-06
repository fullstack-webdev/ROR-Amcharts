class Performance::WellsController < Performance::ModuleController
  before_filter :set_wells_tab

  def index
    @wells ||= Well.completed
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

  def set_wells_tab
    @active_tab = 'wells'
  end
end