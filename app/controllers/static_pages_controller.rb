class StaticPagesController < ApplicationController
    before_filter :signed_in_user, only: [:help, :terms_of_use, :tutorial]

    skip_before_filter :verify_traffic, only: [:home, :solutions, :team, :about, :content, :contact, :terms_of_use, :terms, :privacy, :copyright, :developers, :apps, :pricing]
    skip_before_filter :accept_terms_of_use, only: [:terms_of_use]
    skip_before_filter :session_expiry, only: [:home, :solutions, :team, :about, :content, :contact, :terms, :privacy, :copyright, :developers, :apps, :pricing]
    skip_before_filter :update_session_expiration, only: [:home, :solutions, :team, :about, :content, :contact, :terms, :privacy, :copyright, :developers, :apps, :pricing]

    def home
        respond_to do |format|
            format.html {
              if signed_in?
                if current_user.alerts.any? && !current_user.role.no_assigned_jobs?
                  redirect_to alerts_path
                else
                  redirect_to jobs_path
                end
              elsif signed_in_admin?
                redirect_to users_path
              # else
                #@news = []
                #5.times do |i|
                #    @news << [$redis.get('news_title_' + i.to_s), $redis.get('news_summary_' + i.to_s), $redis.get('news_link_' + i.to_s)]
                #end
              end
            }
            format.xml {
                if signed_in?
                    render :nothing => true, :status => :ok
                else
                    render :nothing => true, :status => :unauthorized
                end
            }
        end
    end

    def help
    end

    def solutions
        set_tab :solutions

        unless params[:page].blank?
            render "static_pages/solutions/#{params[:page]}"
            return
        end
    end

    def content
        set_tab :content

        unless params[:page].blank?
            render "static_pages/content/#{params[:page]}"
            return
        end
    end

    def about
        set_tab :about
    end

    def team
        set_tab :team
    end

    def apps
        set_tab :apps
    end

    def developers
        set_tab :developers
    end

    def pricing
        set_tab :pricing
    end

    def contact
        set_tab :contact
    end

    def terms_of_use
        if params[:accept].present?
            if params[:accept] == "true"
                current_user.update_attribute(:accepted_tou, true)
                #if !signed_in_admin?
                #    redirect_to tutorial_path
                #else
                    redirect_to root_url
                #end
            elsif params[:accept] == "false"
                sign_out
                redirect_to root_url
            end
        end
    end

    def tutorial

    end

    def terms

    end

    def privacy

    end

    def copyright

    end


end
