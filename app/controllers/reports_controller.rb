class ReportsController < ApplicationController
    before_filter :signed_in_user, only: [:status]

    def status
        id = params[:id]
        render json: { id: id, url: $redis.get(id) }
    end

end
