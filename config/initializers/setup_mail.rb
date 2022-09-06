ActionMailer::Base.smtp_settings = {
        :address              => "smtp.gmail.com",
        :port                 => 587,
        :domain               => "www.corva.ai",
        :user_name            => "no-reply@corva.ai",
        :password             => "AICorva4!",
        :authentication       => "plain",
        :enable_starttls_auto => true
}

ActionMailer::Base.default_url_options[:host] = "www.corva.ai" if Rails.env.production?
ActionMailer::Base.default_url_options[:host] = "localhost:3000" if Rails.env.development?
#Mail.register_interceptor(DevelopmentMailInterceptor) if Rails.env.development?