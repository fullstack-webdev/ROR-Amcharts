class InventoryController < ApplicationController
    before_filter :signed_in_user_inventory, only: [:index, :show]
    set_tab :inventory

    include InventoryHelper


    def index
        if params[:district].present?
            @district_present = true
            @district = District.find_by_id(params[:district])
            not_found unless @district.company == current_user.company
        elsif current_user.district.present?
            @district = current_user.district
        elsif current_user.company.districts.where(:master => true).count == 1
            @district = current_user.company.districts.where(:master => true).first.districts.first
        else
            @district = nil
        end

        not_found unless @district.present?
        redirect_to inventory_path(@district)
    end


    def show
        @district = District.find_by_id(params[:id])
        not_found unless @district.present? && @district.company == current_user.company

        @condensed = true



        respond_to do |format|
            format.html {

            }
            format.js {

            }
            format.xlsx {
            }
        end

    end

end
