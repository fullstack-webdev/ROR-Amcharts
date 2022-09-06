class AdminUsersController < ApplicationController
  include JobAnalysisHelper
  before_filter :signed_in_admin
  layout 'admin'

  set_tab :admin_users

  def index
    @companies = Company.all
    @company = Company.find(params[:id])

    respond_to do |format|
      format.html { @admin_users = User.from_company(@company).includes(:district, :company).paginate(page: params[:page], limit: 20) }
      format.js {
        if params[:search].length == 0
          @admin_users = User.from_company(@company).where(:admin => false).paginate(page: params[:page], limit: 20)
        elsif params[:search].length > 1
          @admin_users = User.search(params, @company).results
        end
      }
    end

  end

  def show
    @user = User.find_by_id(params[:id])
    not_found unless @user.present? && @user.company == current_user.company

    @activities = Activity.activities_for_user(@user).paginate(page: params[:page], limit: 20)

    if !current_user.role.limit_to_assigned_jobs?
      @average_job_performance = average_job_performance @user.jobs
      job_count = @user.jobs.count
    end
  end


  def edit
    store_last_location

    @user = User.find_by_id(params[:id])

    puts current_user.company.id
    not_found unless @user.company == current_user.company
    @districts = current_user.company.districts

  end

  def update

    @user = User.find(params[:id])
    not_found unless @user.company == current_user.company

    User.transaction do
      if  @user.update_attribute(:name, params[:user][:name])
        @user.update_attribute(:location, params[:user][:location])
        @user.update_attribute(:phone_number, params[:user][:phone_number])
        @user.update_attribute(:district_id, params[:user][:district_id])
        @user.update_attribute(:role_id, params[:user][:role_id])

        Activity.add(self.current_user, Activity::USER_UPDATED, @user, @user.name)
        flash[:success] = "User updated"
        redirect_back_or users_path
      else
        set_selectors
        render 'edit'
      end
    end
  end

  def new
    store_location

    @user = User.new
    @districts = current_user.company.districts
    @roles = create_roles
  end

  def create
    district_id = params[:user][:district_id]
    params[:user].delete(:district_id)

    role_id = params[:user][:role_id]
    params[:user].delete(:role_id)

    @user = User.new(params[:user])
    @districts = current_user.company.districts
    @user.company = current_user.company
    @user.district = District.find_by_id(district_id)
    @user.role_id = role_id
    password = SecureRandom.urlsafe_base64[1..7]
    @user.password = password
    @user.password_confirmation = password
    @user.create_password = true

    if @user.district.present?
      @user.time_zone = @user.district.time_zone
    end

    if @user.save

      @user.delay.send_welcome_email(@user, password)

      Activity.add(self.current_user, Activity::USER_CREATED, @user, @user.name)

      flash[:success] = "User created - #{@user.email}"

      if signed_in_admin?
        redirect_to users_path
      else
        redirect_to @user
      end
    else
      @districts = current_user.company.districts
      @roles = create_roles
      render 'new'
    end
  end

  def destroy
    @user = User.find_by_id(params[:id])
    not_found unless @user.company == current_user.company

    if !current_user?(@user)
      @user.destroy

      Activity.add(current_user, Activity::USER_DESTROYED, @user, @user.name)
      flash[:success] = "User destroyed."
      redirect_to users_path
    else
      flash[:error] = "Can't delete yourself."
      redirect_to users_path
    end
  end

  private

  def signed_in_support_role
    unless signed_in_admin?
      store_location
      redirect_to signin_url, error: "Please sign in."
    end
  end
end
