class AlertsController < ApplicationController
    before_filter :signed_in_user, only: [:index]

    set_tab :alerts

    def index

        @alerts = current_user.alerts.includes(:company, :created_by, :user, :target).includes(:job).where("alert_type != 3")

        @new_alerts = Array.new
        @old_alerts = Array.new

        @alerts.each do |alert|

            if alert.expiration.nil? or alert.expiration > 6.3.days.from_now or
                    alert.alert_type == Alert::PRE_JOB_DATA_READY or alert.alert_type == Alert::POST_JOB_DATA_READY
                @new_alerts << alert
            else
                @old_alerts << alert
            end

            alert.seen
        end


        @page = (params[:page] || "1").to_i
        @adjusted_today_date = Time.zone.now

            @start_date = Time.zone.now.beginning_of_week - 1.days


        @active_jobs = current_user.active_jobs

    end


end
