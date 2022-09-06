class SettingsController < ApplicationController
    before_filter :signed_in_user, only: [:edit, :update]
    before_filter :signed_in_admin, only: [:security, :update_security]

    def edit
        @user = current_user
    end

    def update

        @user = User.find_by_id(params[:id])
        not_found unless @user.company == current_user.company

        User.transaction do
          @user.phone_number = params[:user][:phone_number]
          @user.save
          flash[:success] = "Settings updated"
          render "edit"
        end
    end

    def security
        @vpn_range = current_user.company.vpn_range
    end

    def update_security
        @vpn_range = current_user.company.vpn_range = params["security"]["vpn_range"]
        if current_user.company.save
            flash[:success] = "Security settings updated"
            redirect_to security_path
        else
            render 'security'
        end
    end

end
