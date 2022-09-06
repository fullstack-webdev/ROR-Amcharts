class WellsController < ApplicationController
  before_filter :signed_in_user, only: [:index, :show]
  before_filter :signed_in_user, only: [:new, :create, :edit, :update]

  set_tab :wells

  def index
    @wells = []
    @programs = Program.all

    respond_to do |format|
      format.html {
        if params[:field_id].present?
          field = Field.find_by_id(params[:field_id])
          if field.company == current_user.company
            @wells = field.wells
          end
        end
      }
      format.js {
        @query = params[:search]
        @wells = Well.search_with_field(params, current_user.company, Field.find_by_id(params[:field_id]))
        if @wells.empty?
          @wells << Well.new
          render json: @wells.map { |well| {:value => "No rig found...", :name => "", :id => -1} }
          return
        end

        if params[:q].present?
          render json: @wells.map { |well| {:name => well.name, :id => well.id} }
        else
          render json: @wells.map { |well| {:label => well.name, :id => well.id} }
        end
      }
    end

  end

  def show

    @well = Well.find_by_id(params[:id])
    not_found unless @well.present? && @well.company == current_user.company

    @jobs = UserRole.limit_jobs_scope current_user, @well.jobs


  end

  def new
    @well = Well.new
    @field = Field.find_by_id(params[:field_id])
  end

  def create
    field_id = params[:well][:field_id]
    params[:well].delete(:field_id)

    rig_id = params[:well][:rig_id]
    params[:well].delete(:rig_id)

    @well = Well.new(params[:well])
    @well.company = current_user.company
    @well.field = Field.find_by_id(field_id)
    @well.rig = Rig.find_by_id(rig_id)
    @well.rig = Rig.find_by_id(rig_id)
    @well.save
  end

  def edit
    store_last_location

    @well = Well.find_by_id(params[:id])
    @field = @well.field
    not_found unless @well.company == current_user.company

    @df = DynamicField.new
    @df.value_type = 10
  end

  def update_info
    puts "=========update_info"
    puts params
    @well = Well.find_by_id(params[:well_id])
    not_found unless @well.present? #&& @well.company == current_user.company

    # if params[:update_field].present? && params[:update_field] == "true" &&
    #     params[:field].present? && params[:value].present?
    #   case params[:field]
    #     when "location"
    #       @well.update_attribute(:location, params[:value])
    #     when "bottom_hole_location"
    #       @well.update_attribute(:bottom_hole_location, params[:value])
    #     when "datum"
    #       @well.update_attribute(:datum, params[:value])
    #     when "rig_id"
    #       @rig = Rig.find_by_id(params[:value])
    #       @well.rig = @rig
    #       @well.save
    #     when "name"
    #       if !params[:value].blank?
    #         @well.update_attribute(:name, params[:value])
    #       end
    #   end
    # else
    #   field_id = params[:well][:field_id]
    #   params[:well].delete(:field_id)
    #
    #   rig_id = params[:well][:rig_id]
    #   params[:well].delete(:rig_id)
    #
    #   Well.transaction do
    #     if @well.update_attributes(params[:well])
    #       @well.rig = Rig.find_by_id(rig_id)
    #       @well.save
    #       flash[:success] = "Well updated"
    #       redirect_back_or root_path
    #     else
    #       render 'edit'
    #     end
    #   end
    # end
  end

  def update

    @well = Well.find_by_id(params[:id])
    not_found unless @well.present? && @well.company == current_user.company

    if params[:update_field].present? && params[:update_field] == "true" &&
        params[:field].present? && params[:value].present?
      case params[:field]
          when "location"
          @well.update_attribute(:location, params[:value])
        when "bottom_hole_location"
          @well.update_attribute(:bottom_hole_location, params[:value])
        when "datum"
          @well.update_attribute(:datum, params[:value])
        when "field_id"
          @well.update_attribute(:field_id, params[:value])
        when "offset_well_id"
          @well.update_attribute(:offset_well_id, params[:value])
        when "drilling_company"
          @well.update_attribute(:drilling_company, params[:value])
        when "fluid_company"
          @well.update_attribute(:fluid_company, params[:value])
        when "county"
          @well.update_attribute(:county, params[:value])
        when "well_number"
          @well.update_attribute(:well_number, params[:value])
        when "api_number"
          @well.update_attribute(:api_number, params[:value])
        when "program_ids"
          @well.programs.clear
          @well.programs << Program.find_all_by_id(params[:value].split(",").select { |c| !c.empty? }.map { |s| s.to_i })
          @well.save
        when "rig_id"
          @rig = Rig.find_by_id(params[:value])
          @well.rig = @rig
          @well.save
        when "name"
          if !params[:value].blank?
            @well.update_attribute(:name, params[:value])
          end
        when "section_curve_start"
              @well.jobs.first.update_attribute(:section_curve_start, params[:value].gsub(',', ''))
        when "section_tangent_start"
              @well.jobs.first.update_attribute(:section_tangent_start, params[:value].gsub(',', ''))
      end
    else
      field_id = params[:well][:field_id]
      params[:well].delete(:field_id)

      rig_id = params[:well][:rig_id]
      params[:well].delete(:rig_id)

      Well.transaction do
        if @well.update_attributes(params[:well])
          @well.rig = Rig.find_by_id(rig_id)
          @well.save
          flash[:success] = "Well updated"
          redirect_back_or root_path
        else
          render 'edit'
        end
      end
    end

  end

  def autocomplete_well_name
    field_id = params[:field_id]
    wells = Well.where('field_id = ?', field_id).order(:name).all
    render :json => wells.map { |well| {:id => well.id, :label => well.name, :value => well.name} }
  end

end
