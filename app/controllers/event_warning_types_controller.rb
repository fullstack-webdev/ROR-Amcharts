class EventWarningTypesController < ApplicationController
  before_filter :signed_in_admin
  before_filter :render_companies
  layout 'admin'
  set_tab :warnings

  def index
    @warning_types =  EventWarningType.per_page_kaminari.page(params[:page]).per(1000)
  end

  def new
    @warning_type = EventWarningType.new
  end

  def create
    @warning_type = EventWarningType.new(params[:event_warning_type])
    if @warning_type.save
      flash[:success] = "Warning created - #{@warning_type.name}"
      redirect_to event_warning_types_path
    else
      flash[:error] = "Warning creation failed!<br/><br/>".html_safe
      flash[:error] += @warning_type.errors.full_messages.join("<br/>").html_safe
      render action: :new
    end
  end

  def show
    @warning_type = EventWarningType.find_by_id(params[:id])
    not_found if @warning_type.nil?
  end

  def edit
    @warning_type = EventWarningType.find_by_id(params[:id])
    not_found if @warning_type.nil?
  end

  def update
    @warning_type = EventWarningType.find_by_id(params[:id])
    if @warning_type.update_attributes(params[:event_warning_type])
      flash[:success] = "Warning updated - #{@warning_type.name}"
      redirect_to event_warning_types_path
    else
      flash[:error] = "Warning update failed!<br/><br/>".html_safe
      flash[:error] += @warning_type.errors.full_messages.join("<br/>").html_safe
      render action: :edit
    end
  end

  def destroy
    @warning_type = EventWarningType.find_by_id(params[:id])
    if @warning_type.destroy
      flash[:success] = "Warning deleted"
      redirect_to event_warning_types_path
    else
      flash[:error] = "Warning deletion failed!"
      render action: :edit
    end
  end

  private

  def render_companies
    @companies = Company.all
    @company = nil
  end
end
