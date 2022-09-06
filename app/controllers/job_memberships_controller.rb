class JobMembershipsController < ApplicationController
    before_filter :signed_in_user, only: [:new, :create, :edit, :update, :destroy]

    def new
        @job_membership = JobMembership.new
    end

    def create
        job_id = params[:job_membership][:job_id]
        params[:job_membership].delete(:job_id)

        user_id = params[:job_membership][:user_id]
        params[:job_membership].delete(:user_id)

        @job = Job.find_by_id(job_id)
        not_found unless @job.company == current_user.company

        @job_membership = JobMembership.new(params[:job_membership])
        if !user_id.blank?
            @job_membership.job_role_id = params[:job_role_id]
            @user = User.find_by_id(user_id)
            @job_membership.user = @user
            if @user.present?
                @job_membership.user_name = @user.name
            end
        elsif params[:user_name].present?
            @job_membership.job_role_id = params[:job_role_id2]
            @job_membership.external_user = true
            @job_membership.user_name = params[:user_name]
            @job_membership.phone_number = params[:phone_number]
            @job_membership.email = params[:email]
        end
        @job_membership.job = @job
        @job_membership.company = @job.company

        if @job_membership.job_role_id.present? && @job_membership.job_role_id >= 1000
            case @job_membership.job_role_id
                when 1000
                    @job_membership.job_role_id = JobMembership::FIELD
                    @job_membership.shift_type = JobMembership::SHIFT_DAY
                when 1001
                    @job_membership.job_role_id = JobMembership::FIELD
                    @job_membership.shift_type = JobMembership::SHIFT_NIGHT
                when 1005
                    @job_membership.job_role_id = JobMembership::COMPANY_MAN
                    @job_membership.shift_type = JobMembership::SHIFT_DAY
                when 1006
                    @job_membership.job_role_id = JobMembership::COMPANY_MAN
                    @job_membership.shift_type = JobMembership::SHIFT_NIGHT
            end
        end

        if @job_membership.save
            if @user.present? && current_user.id != @user.id
                @user.delay.send_added_to_job_email(@job)
            end

            Activity.add(self.current_user, Activity::JOB_MEMBER_ADDED, @job_membership, @job_membership.user_name, @job)

            if @user.present?
                Alert.add(@user, Alert::ADDED_TO_JOB, @job, current_user, @job)
            end
        else
            #render template: 'layouts/error', locals: {title: "Problem Adding Member", object: @job_membership}
        end
    end

    def edit
        @job_membership = JobMembership.find_by_id(params[:id])
        not_found unless @job_membership.job.company == current_user.company
    end

    def update
        @job_membership = JobMembership.find_by_id(params[:id])
        not_found unless @job_membership.job.company == current_user.company

        if @job_membership.external_user?
            if params[:user_name].present?
                @job_membership.job_role_id = params[:job_role_id2]
                @job_membership.user_name = params[:user_name]
                @job_membership.phone_number = params[:phone_number]
                @job_membership.email = params[:email]
                @job_membership.save
            end
        else
            @job_membership.update_attribute(:job_role_id, params[:job_role_id])
        end

        if @job_membership.job_role_id && @job_membership.job_role_id >= 1000
            case @job_membership.job_role_id
                when 1000
                    @job_membership.update_attribute(:job_role_id, JobMembership::FIELD)
                    @job_membership.update_attribute(:shift_type, JobMembership::SHIFT_DAY)
                when 1001
                    @job_membership.update_attribute(:job_role_id, JobMembership::FIELD)
                    @job_membership.update_attribute(:shift_type, JobMembership::SHIFT_NIGHT)
                when 1005
                    @job_membership.update_attribute(:job_role_id, JobMembership::COMPANY_MAN)
                    @job_membership.update_attribute(:shift_type, JobMembership::SHIFT_DAY)
                when 1006
                    @job_membership.update_attribute(:job_role_id, JobMembership::COMPANY_MAN)
                    @job_membership.update_attribute(:shift_type, JobMembership::SHIFT_NIGHT)
            end
        else
            @job_membership.update_attribute(:shift_type, JobMembership::SHIFT_NONE)
        end
    end

    def destroy
        @job_membership = JobMembership.find_by_id(params[:id])
        if @job_membership.present?
            not_found unless @job_membership.job.company == current_user.company
            @job_membership.destroy
        end
    end
end
