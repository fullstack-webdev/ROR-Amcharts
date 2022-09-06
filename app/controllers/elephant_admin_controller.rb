class ElephantAdminController < ApplicationController
    before_filter :elephant_admin_user, only: [:index]

    def index
        @companies = Company.all
    end

    private

    def elephant_admin_user
        redirect_to(root_path) unless signed_in? && current_user.elephant_admin?
    end
end
