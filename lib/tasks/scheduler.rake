task :update_wellbore_sections => :environment do
    Time.zone = "Central Time (US & Canada)"

    Job.where("jobs.status = :on_job OR (jobs.status = :complete AND jobs.end_date >= :end)", on_job: Job::ON_JOB, complete: Job::COMPLETE, end: 24.hours.ago).find_each do |job|
        begin
            job.update_wellbore_sections
        rescue => e
            puts "caught exception #{e}"
        end
    end
end



task :daily_activity_email => :environment do
    Time.zone = "Central Time (US & Canada)"
    User.all.each do |user|
        #user = User.find(85)

        if !user.admin? && user.send_daily_activity

            jobs = !user.role.limit_to_assigned_jobs? ? user.company.jobs.reorder('') : user.jobs
            #jobs = user.role.no_assigned_jobs? ? user.company.jobs.reorder('') : user.jobs
            jobs = jobs.includes(dynamic_fields: :dynamic_field_template).includes(:job_memberships, :field, :well, :documents, :district, :client, :job_template => {:primary_tools => :tool}).includes(job_template: {product_line: {segment: :division}}).where("(jobs.status >= 1 AND jobs.status < 50) OR (jobs.status = :status_closed AND jobs.close_date >= :close_date)", status_closed: Job::COMPLETE, close_date: (Time.now - 5.days)).
                    order("jobs.created_at DESC")
            if jobs.any?
                begin
                    UserMailer.daily_activity_report(user, jobs).deliver
                rescue
                    UserMailer.daily_activity_report(user, jobs).deliver
                end
            end
        end
    end
end

task :timesheet_email => :environment do
    Time.zone = "Central Time (US & Canada)"

    Company.find_each do |company|
        start_date = Time.now.beginning_of_week
        if start_date.wday == 0
            week = start_date.strftime("%U").to_i
            if company.payroll_schedule == Company::PAYROLL_BIMONTHLY_EVEN && week % 2 != 0
                if week % 2 != 0
                    start_date = start_date - 1.week
                else
                    start_date = start_date - 3.weeks
                end

                users = User.includes(:job_times).where("users.role_id = 30 OR users.role_id = 31 OR users.role_id = 35 OR users.role_id = 36").order("users.name ASC")
                users.each_with_index do |user, index|
                    UserMailer.timesheet_report(user, start_date).deliver
                end
            end
        elsif start_date.wday == 1
            week = start_date.strftime("%U").to_i
            if company.payroll_schedule == Company::PAYROLL_BIMONTHLY_EVEN && week % 2 == 0
                if week % 2 != 0
                    start_date = start_date - 1.week
                else
                    start_date = start_date - 3.weeks
                end

                users_sql = JobMembership.includes(:user).joins(:job).where("(jobs.status >= 1 AND jobs.status < 50) OR (jobs.status = :status_closed AND jobs.close_date >= :close_date)", status_closed: Job::COMPLETE, close_date: (Time.now - 14.days)).where("job_memberships.job_role_id = ?", JobMembership::COORDINATOR).select("DISTINCT (job_memberships.user_id)").to_sql
                users = User.where("users.id IN (#{users_sql})")
                users.each do |user|
                    UserMailer.timesheet_report_ready(user, start_date).deliver
                end
            end
        end
    end
end

task :inactive_job_email => :environment do
    Job.joins(:activities).where("jobs.status >= 5 AND jobs.status <= 7").having("count(activities.created_at > :date) = 0", date: 1.month.ago - 1.day).group("jobs.id").each do |job|
        creator = job.get_role(JobMembership::CREATOR)
        coordinator = job.get_role(JobMembership::COORDINATOR)

        if !coordinator.nil?
            JobProcessMailer.job_inactive(coordinator, job).deliver
        end
        if !creator.nil? && coordinator != creator
            JobProcessMailer.job_inactive(creator, job).deliver
        end
    end
end


task :new_message_alert => :environment do
    Time.zone = "Central Time (US & Canada)"

    twilio_sid = "ACb8d3e553fce250437a90365ab774283f"
    twilio_token = "2881efb95b96996487560a1e2ead7351"

    @twilio_client = Twilio::REST::Client.new twilio_sid, twilio_token

    Alert.where("alerts.alert_type = :message_type AND alerts.created_at <= :start AND alerts.created_at >= :end", message_type: Alert::NEW_MESSAGE, start: Time.zone.now - 10.minutes, end: Time.zone.now - 20.minutes).find_each do |alert|
        begin
            if alert.user.present? && !alert.user.phone_number.blank?
                conversation = alert.target
                message = conversation.messages.last
                if message.user != alert.user
                    @twilio_client.account.sms.messages.create(
                            :from => "+18175000360",
                            :to => (alert.user.company.test_company? ? "+1-512-507-0072" : alert.user.phone_number),
                            :body => "#{message.user.name} sent you a message on Corva. '#{message.text.length > 100 ? message.text[0..100] + '...' : message.text}' View at www.corva.ai."
                    )
                end
            end
        rescue
        end
    end
end



