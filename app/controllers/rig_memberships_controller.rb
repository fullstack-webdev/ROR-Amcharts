class RigMembershipsController < ApplicationController
    before_filter :signed_in_user, only: [:new, :create, :destroy]

    def new
        @rig_membership = RigMembership.new
    end

    def create
        rig_id = params[:rig_membership][:rig_id]
        params[:rig_membership].delete(:rig_id)

        user_id = params[:rig_membership][:user_id]
        params[:rig_membership].delete(:user_id)

        @rig = Rig.find_by_id(rig_id)

        @rig_membership = RigMembership.new(params[:rig_membership])
        if !user_id.blank?
            @user = User.find_by_id(user_id)
            @rig_membership.user = @user
        end
        @rig_membership.rig = @rig
        @rig_membership.company = current_user.company
        @rig_membership.save
    end

    def destroy
        @rig_membership = RigMembership.find_by_id(params[:id])
        not_found unless @rig_membership.present?
        @rig_membership.destroy
    end

end
