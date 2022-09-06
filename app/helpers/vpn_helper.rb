module VpnHelper

    def verify_traffic(resend = false)
        if signed_in? && !signed_in_super_admin?
            if current_user.company.vpn_range.present?
                remote_ip = request.remote_ip.to_ip

                if current_user.unverified_network.present? && current_user.unverified_network.to_ip == remote_ip
                    if !resend
                        redirect_to verify_network_path
                        return
                    end
                end

                acceptable = false

                #check company verified network ranges
                ranges = current_user.company.vpn_range.split(",")
                ranges.each do |range|
                    inner_range = range.split("-")
                    if inner_range.count > 1
                        acceptable = (inner_range.first.to_ip..inner_range.last.to_ip).include?(remote_ip)
                    else
                        acceptable = inner_range.first.to_ip == remote_ip
                    end

                    if acceptable
                        break
                    end
                end

                # check verified networks
                if !acceptable && !current_user.verified_networks.blank?
                    ranges = current_user.verified_networks.split(",")
                    ranges.each do |range|
                        acceptable = range.to_ip == remote_ip
                        if acceptable
                            break
                        end
                    end

                end

                unless acceptable
                    send_temporary_access_code
                    sign_out
                    if request.format == :xml
                        render :nothing => true, :status => :expectation_failed
                        return
                    end
                    deny_access "You are accessing Corva from a computer network not within your company policy. Please check your email for a special access code to authorize this network."
                end
            end
        end
    end

    def send_temporary_access_code
        password = SecureRandom.urlsafe_base64[1..7]
        if current_user.update_attribute(:unverified_network, request.remote_ip) &&
                current_user.update_attribute(:network_access_code, password)
            current_user.delay.send_remote_login_password_email(password)
        else
            puts current_user.errors.messages.inspect
        end
    end

    def authorize_network_code(code)
        if current_user.network_access_code == code && request.remote_ip.to_ip == current_user.unverified_network.to_ip
            current_user.update_attribute(:unverified_network, nil)
            current_user.update_attribute(:network_access_code, nil)
            if current_user.verified_networks.blank?
                current_user.update_attribute(:verified_networks, request.remote_ip)
            else
                current_user.update_attribute(:verified_networks, current_user.verified_networks + "," + request.remote_ip)
            end
            true
        end

        false
    end

end

class String
    def to_ip
        split(".").inject(0) { |s, p| (s << 8) + p.to_i }
    end
end