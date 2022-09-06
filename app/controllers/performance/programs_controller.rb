class Performance::ProgramsController < Performance::ModuleController
  before_filter :set_programs_tab

  def index
    @programs ||= Program.includes(:wells).select { |program| program.wells.count > 0 }
  end

  def get_histogram
    if (params[:program_id] && params[:history_id])
      if params['program_id'].to_i == -1
        programs = Program.includes(:wells).select { |program| program.wells.count > 0 }
      else
        programs = Program.where(id: params['program_id'])
      end

      wits_category_histogram = Hash.new
      programs.each do |program|
        # wits_category_histogram[program.id] = program.program_wits_category_histogram(params['history_id'])
        wits_category_histogram[program.id] = program.histogram
      end

      render json: wits_category_histogram.to_json
    else
      render json: {errors: 'Invalid parameters'}, status: 400
    end
  end

  private

  def set_programs_tab
    @active_tab = 'programs'
  end
end