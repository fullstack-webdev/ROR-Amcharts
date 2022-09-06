class CompaniesController < ApplicationController
    before_filter :elephant_admin_user, only: [:new, :destroy, :create]
    before_filter :signed_in_user, only: [:show]
    before_filter :signed_in_admin_user, only: [:edit, :update]
    layout 'admin', only: [:new]

    def show
        @company = current_user.company
        @users = User.from_company(@company).includes(:district, :company).where(:admin => false).paginate(page: params[:page], limit: 20)
    end

    def new
        @companies = Company.all
        @company = Company.new
    end

    def destroy
        Company.find_by_id(params[:id]).destroy
        flash[:success] = "Company destroyed."
        # redirect_to elephant_admin_path
        redirect_to admin_path
    end

    def create
        @company = Company.new(params[:company])
        if @company.save

            district = District.new(name: "Global")
            district.company = @company
            district.save


            CompanyFeature.possible_features.each do |f|
                feature = CompanyFeature.new
                feature.company = company
                feature.feature = f
                if CompanyFeature.is_free_tier f
                    feature.enabled = true
                else
                    feature.enabled = false
                end
                feature.save
            end

            flash[:success] = "Company created."
            # redirect_to elephant_admin_path
            redirect_to "/admin/company/#{@company.id}"
        else
            render 'new'
        end
    end

    def edit
        @companies = Company.all
        @company = Company.find_by_id(params[:id])

        if signed_in_admin?
            current_user.company = @company
        end
    end

    def update
        @company = Company.find_by_id(params[:id])
        not_found unless @company == current_user.company || signed_in_super_admin?

        if params[:update_field].present? && params[:update_field] == 'true' &&
                params[:field].present? && params[:value].present?
            if params[:field] == "test_company"
                @company.update_attribute(:test_company, params[:value] == "true")
            end
            if params[:field] == "name"
                @company.update_attribute(:name, params[:value])
            end
            if params[:field] == "phone_number"
                @company.update_attribute(:phone_number, params[:value])
            end
            if params[:field] == "support_email"
                @company.update_attribute(:support_email, params[:value])
            end
            render :nothing => true, :status => :ok
            return
        end

        if @company.update_attributes(params[:company])
            flash[:success] = "Company info updated"
            redirect_to "/admin/company/#{@company.id}/settings"
        else
            render 'edit'
        end
    end

    private

    def elephant_admin_user
        redirect_to root_path unless signed_in? && current_user.elephant_admin?
    end
end
