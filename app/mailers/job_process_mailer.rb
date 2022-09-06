class JobProcessMailer < ActionMailer::Base
    default from: "\"Corva\" <no-reply@corva.ai>"

    def pre_job_data_complete(user, job)
        @user = user
        @job = job
        mail(:to => user.company.test_company ? "test-emails@corva.ai" : user.email,
             :subject => "Pre-Job Complete: #{@job.field.name} | #{@job.well.name}")
    end

    def post_job_data_complete(user, job)
        @user = user
        @job = job
        mail(:to => user.company.test_company ? "test-emails@corva.ai" : user.email,
             :subject => "Post-Job Complete: #{@job.field.name} | #{@job.well.name} | #{@job.job_template.name}")
    end

    def ship_to_field(user, job)
        @user = user
        @job = job
        mail(:to => user.company.test_company ? "test-emails@corva.ai" : user.email,
             :subject => "Job Shipping to Location: #{@job.field.name} | #{@job.well.name} | #{@job.job_template.name}")
    end

    def job_complete(user, job)
        @user = user
        @job = job
        mail(:to => user.company.test_company ? "test-emails@corva.ai" : user.email,
             :subject => "Job Complete: #{@job.field.name} | #{@job.well.name} | #{@job.job_template.name}")
    end

    def added_to_job(user, job)
        @user = user
        @job = job
        mail(:to => user.company.test_company ? "test-emails@corva.ai" : user.email,
             :subject => "Added to Job: #{@job.field.name} | #{@job.well.name} | #{@job.job_template.name}")
    end

    def job_inactive(user, job)
        @user = user
        @job = job
        mail(:to => user.company.test_company ? "test-emails@corva.ai" : user.email,
             :subject => "Job Low Activity Alert")
    end

    def asset_not_received(user, job)
        @user = user
        @job = job
        mail(:to => user.company.test_company ? "test-emails@corva.ai" : user.email,
             :subject => "Job Asset Not Received")
    end
end
