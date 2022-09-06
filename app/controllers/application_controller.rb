class ApplicationController < ActionController::Base
    protect_from_forgery
    include SessionsHelper
    include VpnHelper

    before_filter :session_expiry
    before_filter :update_session_expiration

    before_filter :verify_traffic

    before_filter :set_current_user_for_observer
    before_filter :set_user_time_zone
    before_filter :set_locale

    before_filter :accept_terms_of_use

    set_current_tenant_through_filter
    before_filter :set_tenant

    before_filter :check_for_mobile

    def set_new_configuration(job_id, entry_at)
      $redis_data_layer.set('is_config_set' + job_id, "yes")
      $redis_data_layer.set('config_date' + job_id, entry_at)
    end

    def session_expiry
        if (!request.headers['x-access-token'].blank? || !request.params['x_access_token'].blank?) && current_user
        elsif controller_name == 'admin'
        else
            get_session_time_left
        end
    end

    def check_for_mobile
      session[:mobile_override] = params[:mobile] if params[:mobile]
      prepare_for_mobile if mobile_device?
    end

    def prepare_for_mobile
      prepend_view_path Rails.root + 'app' + 'views_mobile'
    end

    def mobile_device?
      if session[:mobile_override]
        session[:mobile_override] == "1"
      else
        #(request.user_agent =~ /Mobile|webOS/) && (request.user_agent !~ /iPad/)
        (request.user_agent =~ /Mobile|webOS/)
      end
    end
    helper_method :mobile_device?

    private

    def get_session_time_left
        expire_time = session[:expires_at] || Time.now
        @session_time_left = (expire_time - Time.now).to_i

        unless @session_time_left > 0
            if URI(request.url).path == 'pusher/auth'
                render :text => "Forbidden", :status => '403'
                return
            end
            sign_out
            deny_access
        end
    end

    def accept_terms_of_use
        if signed_in? and !current_user.accepted_tou?
            redirect_to terms_of_use_path
        end
    end


    def set_current_user_for_observer
        UserObserver.current_user = current_user
    end


    def set_tenant
        if current_user.present?
            set_current_tenant(current_user.company)
        end
    end

    def signed_in_user
        unless signed_in?
            store_location
            redirect_to signin_url, error: "Please sign in."
        end
    end

    def signed_in_user_inventory
        unless signed_in? && current_user.role.access_to_inventory?
            store_location
            redirect_to signin_url, error: "Please sign in."
        end
    end

    def signed_in_user_not_field
        unless signed_in? && !current_user.role.limit_to_assigned_jobs?
            store_location
            redirect_to signin_url, error: "Please sign in."
        end
    end

    def signed_in_admin
        unless signed_in_super_admin?
            store_location
            redirect_to admin_login_url, error: "Please sign in."
        end
    end

    def not_found
        raise ActionController::RoutingError.new('Not Found')
    end

    private

    def set_user_time_zone
        if signed_in?
            Time.zone = current_user.present? && current_user.time_zone.present? ? current_user.time_zone : "Central Time (US & Canada)"
        else
            Time.zone = "Central Time (US & Canada)"
        end
    end

    def set_locale
        I18n.locale = params[:locale] if params[:locale].present?
        # current_user.locale
        # request.subdomain
        # request.env["HTTP_ACCEPT_LANGUAGE"]
        # request.remote_ip
    end
end
