module SessionsHelper

    def sign_in(user, permanent)
        if permanent
          cookies.permanent[:remember_token] = user.remember_token
        else
          cookies[:remember_token] = user.remember_token
        end

        UserLogin.add(user, request.remote_ip.to_ip)
        user.delay.update_attribute(:invalid_login_attempts, 0)
        update_session_expiration

        self.current_user = user
    end

    def signed_in?
        !current_user.nil?
    end

    def signed_in_admin?
        !current_user.nil? && current_user.admin?
    end

    def signed_in_super_admin?
      !current_user.nil? && current_user.elephant_admin?
    end

    def current_user=(user)
        @current_user = user
    end

    def current_user
        if @current_user

        else
            @current_user ||= User.find_by_remember_token(cookies[:remember_token])

            if @current_user.nil? && (!request.headers['x-access-token'].blank? || !request.params['x_access_token'].blank?)
                x_access_token = !request.headers['x-access-token'].blank? ? request.headers['x-access-token'] : request.params['x_access_token']
                x_user = !request.headers['x-user'].blank? ? request.headers['x-user'] : request.params['x_user']
                api_key = ApiKey.find_by_access_token(x_access_token)
                if api_key.present? && api_key.user_id == x_user.to_i
                    @api_request = true
                    @current_user ||= api_key.user
                    self.current_user = @current_user
                end
            end
        end

        # for company admin impersonation from super admin
        if session[:company_id].present? && @current_user.present? && @current_user.elephant_admin?
          @current_user.company_id = session[:company_id]
          if Company.exists?(session[:company_id])
            @current_user.company = Company.find(session[:company_id])
          else
          end
        end
        self.current_user = @current_user
        return @current_user
    end

    def company_unit
      @current_user.try(:company).try(:company_unit_str) || ''
    end

    def current_user?(user)
        user == current_user
    end

    def sign_out
        session[:return_to] = nil
        session[:company_id] = nil
        self.current_user = nil
        cookies.delete(:remember_token)
    end

    def update_session_expiration
        session[:expires_at] = 5.days.from_now
    end

    def deny_access(msg = nil)
        msg ||= "Session has expired. Please sign in."
        flash[:error] ||= msg
        respond_to do |format|
            format.html {
                store_location
                redirect_to root_url
            }
            format.js {
                store_last_location
                render 'sessions/redirect_to_login', :layout => false
            }
        end
    end


    def signed_in_user
        unless signed_in?
            store_location
            redirect_to root_url, notice: "Please sign in."
        end
    end

    def signed_in_admin_user
        unless signed_in? && current_user.admin_user?
            store_location
            redirect_to root_url, notice: "Please sign in."
        end
    end


    def redirect_back_or(default)
        if session[:return_to].present?
            uri = URI.parse(session[:return_to])
            if !uri.nil? && uri.path != '/pusher/auth'
                redirect_to(session[:return_to] || default)
            else
                redirect_to(default)
            end
        else
            redirect_to(default)
        end
        session.delete(:return_to)
    end

    def store_location
        session[:return_to] = request.url
    end

    def store_last_location
        session[:return_to] = request.referer
    end

end
