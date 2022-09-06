class SearchController < ApplicationController
    before_filter :signed_in_user, only: [:index]

    def index
        respond_to do |format|
            format.html do
              @jobs = Job.search(params[:search], current_user.company, params[:sort])
            end
        end
    end

end
