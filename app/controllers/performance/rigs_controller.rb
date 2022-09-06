class Performance::RigsController < Performance::ModuleController
  before_filter :set_rigs_tab

  def index
    @rigs ||= Rig.includes(:wells)
    @rig_id = params[:id] || -1
    @history_id = params[:history] || -1
  end

  def get_histogram
    if !valid_histogram_param
      render json: {errors: 'Invalid parameters'}, status: 400 and return
    end

    if params['rig_id'].to_i == -1
      rigs = Rig.includes(:wells)
    else
      rigs = Rig.where(id: params['rig_id']).includes(:wells)
    end

    wits_category_histogram = {}
    rigs.each do |rig|
      # wits_category_histogram[rig.id] = rig.rig_wits_category_histogram(params['history_id'])
      wits_category_histogram[rig.id] = rig.histogram
    end

    render json: wits_category_histogram.to_json
  end

  private

  def valid_histogram_param
    params[:rig_id] && params[:history_id]
  end

  def set_rigs_tab
    @active_tab = 'rigs'
  end
end