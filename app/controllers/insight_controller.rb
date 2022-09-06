class InsightController < ApplicationController
    before_filter :signed_in_user, only: [:index]
    set_tab :insight

    def index

    end

end
