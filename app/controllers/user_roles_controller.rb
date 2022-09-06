class UserRolesController < ApplicationController
    before_filter :signed_in_admin, only: [:index, :show, :update]

    set_tab :roles

    def index
        @roles = UserRole.from_company(current_user.company)
    end

    def show
        @role = UserRole.from_role(params[:id], current_user.company)
    end

    def update
        puts "Start..........."
        @role = UserRole.from_role(params[:user_role][:role_id], current_user.company)

        if @role.title != params[:user_role][:title]
            puts "different.........."

            UserRole.transaction do
                existing_role = UserRole.where("company_id = :company_id AND role_id = :role_id", company_id: current_user.company.id, role_id: @role.role_id).limit(1).first
                if existing_role
                    existing_role.destroy
                end
                @role.title = params[:user_role][:title]
                @role.save

                flash[:success] = "User Role updated"
            end
        end

        redirect_to user_roles_path
    end

end
