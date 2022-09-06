class UserMailer < ActionMailer::Base
    layout 'email_layout'

    #before_action :set_images

    default from: "Corva <no-reply@corva.ai>"

    def registration_confirmation(user, password)
        set_images
        @user = user
        @password = password
        mail(:to => user.company.test_company ? "test-emails@corva.ai" : user.email,
             :subject => "New Corva Account for #{@user.company.name}")
    end

    def reset_password(user, password)
        set_images
        @user = user
        @password = password
        mail(:to => user.company.test_company ? "test-emails@corva.ai" : user.email,
             :subject => "Corva Password Reset")
    end

    def remote_login_password(user, password)
        @user = user
        @password = password
        mail(:to => user.company.test_company ? "test-emails@corva.ai" : user.email,
             :subject => "Your Corva Login Code")
    end


    def daily_activity(user, activities)
        @user = user
        @activities = activities
        mail(:to => user.company.test_company ? "test-emails@corva.ai" : user.email,
             :subject => "Corva Daily Job Activity")
    end

    def daily_activity_report(user, jobs)
        @user = user
        @jobs = jobs
        mail(:to => user.company.test_company ? "test-emails@corva.ai" : user.email,
             :subject => "Daily Job Activity Report")
    end

    def alert(user, alert)
        @user = user
        @alert = alert
        mail(:to => user.company.test_company ? "test-emails@corva.ai" : user.email,
             :subject => "You were assigned a task from " + alert.created_by.name)
    end

    def new_message(user, message)
        @user = user
        @message = message
        mail(:to => user.company.test_company ? "test-emails@corva.ai" : user.email,
             :subject => "You received a message from " + message.user.name)
    end

    def desktop_app(user)
        @user = user
        mail(:to => user.company.test_company ? "test-emails@corva.ai" : user.email,
             :subject => "Access Corva Documents Offline")
    end

    def new_notice_on_job(user, job, document)
        @user = user
        @job = job
        @document = document
        mail(:to => user.company.test_company ? "test-emails@corva.ai" : user.email,
             :subject => "New Notice Added on: #{@job.field.name} | #{@job.well.name}")
    end

    def timesheet_report(user, start_date)
        @user = user
        @start_date = start_date
        mail(:to => user.company.test_company ? "test-emails@corva.ai" : user.email,
             :subject => "Corva Timesheet Review")
    end

    def timesheet_report_ready(user, start_date)
        @user = user
        @start_date = start_date
        mail(:to => user.company.test_company ? "test-emails@corva.ai" : user.email,
             :subject => "Corva Timesheets Review")
    end


    private

    def set_images
        if Rails.env.production?
            attachments.inline['corva-logo.png'] = File.read('http://www.corva.ai/assets/corva-logo.png')
        else
            attachments.inline['corva-logo.png'] = File.read(Rails.root.join('app/assets/images/corva-logo.png'))
        end
    end


end
