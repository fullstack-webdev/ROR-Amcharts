class ActivitiesController < ApplicationController
    before_filter :signed_in_user, only: [:index, :show]

    include ActivityExportHelper

    def index

        respond_to do |format|
            format.js {
                @job = Job.find_by_id(params[:job_id])
                not_found unless @job.company == current_user.company

                @activities = Activity.activities_for_job(@job)
            }
            format.html {
                @activities = Activity.admin_activities_for_company(current_user.company).paginate(page: params[:page], limit: 10)
            }
        end
    end

    def show
        respond_to do |format|
            format.xlsx do
                if params[:job_activity] == "true"
                    @job = Job.find_by_id(params[:id])
                    not_found unless @job.company == current_user.company

                    @activities = Activity.activities_for_job(@job)

                    excel = job_to_excel(@activities, @job)
                    send_data excel.to_stream.read, :filename => "#{@job.id.to_s} Job Activity.xlsx", :type => "application/vnd.openxmlformates-officedocument.spreadsheetml.sheet"
                elsif params[:user_activity] == "true"
                    @user = User.find_by_id(params[:id])
                    not_found unless @user.company == current_user.company

                    @activities = Activity.activities_for_user(@user)

                    excel = user_to_excel(@activities, @user)
                    send_data excel.to_stream.read, :filename => "#{@user.name} Activity.xlsx", :type => "application/vnd.openxmlformates-officedocument.spreadsheetml.sheet"
                end
            end
        end
    end
end
