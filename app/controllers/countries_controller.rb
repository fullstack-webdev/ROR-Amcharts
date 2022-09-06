class CountriesController < ApplicationController
    before_filter :signed_in_admin, only: [:show]

    def show
        @country = Country.find_by_id(params[:id])
        @states = @country.states
    end

end
