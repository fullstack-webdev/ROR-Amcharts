class CompanyFeaturesController < ApplicationController
    before_filter :signed_in_admin
    set_tab :admin


    def update
        if params[:update_field].present? && params[:update_field] == 'true' &&
                params[:field].present? && params[:value].present?

            company = Company.find(params[:id])
            feature_id = params[:field].to_i
            if feature_id != 0

                feature = CompanyFeature.where(:company_id => company.id).where(:feature => feature_id).first
                if feature == nil
                    feature = CompanyFeature.new
                    feature.company = company
                end
                feature.feature = feature_id
                feature.enabled = params[:value] == 'true'
                feature.save
            end
        end

        render :nothing => true, :status => :ok
    end
end
