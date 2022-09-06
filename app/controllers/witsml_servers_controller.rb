class WitsmlServersController < ApplicationController
    before_filter :signed_in_admin_user, only: [:index, :create, :destroy, :wells, :connected, :import]

    def index
        set_tab :wells

        @show_servers = true
        @witsml_servers = WitsmlServer.all

        if params[:witsml_server].present?
            @witsml_server = WitsmlServer.find_by_id(params[:witsml_server])
            @show_servers = false
        elsif @witsml_servers.count == 1
            redirect_to witsml_servers_path(witsml_server: @witsml_servers.first)
        end
    end

    def create
        @witsml_server = WitsmlServer.new
        @witsml_server.company = current_user.company
        @witsml_server.location = params[:witsml_server][:location]
        @witsml_server.username = params[:witsml_server][:username]
        @witsml_server.password = params[:witsml_server][:password]

        if @witsml_server.save

        end
    end

    def destroy
        @witsml_server = WitsmlServer.find_by_id(params[:id])
        not_found unless @witsml_server.present?
        @witsml_server.destroy
    end

    def wells
        @witsml_server = WitsmlServer.find_by_id(params[:id])
        not_found unless @witsml_server.present?

        @wells = JSON.parse(@witsml_server.get_well_list)

        #respond_to do |format|
        #    format.json { render json: wells }
        #end
    end

    def connected
        @witsml_server = WitsmlServer.find_by_id(params[:id])
        not_found unless @witsml_server.present?

        connected = @witsml_server.connected?

        respond_to do |format|
            format.json { render json: connected }
        end
    end


    def import
        @witsml_server = WitsmlServer.find_by_id(params[:id])
        not_found unless @witsml_server.present?

        well_id = params["well_id"]
        wellbore_id = params["wellbore_id"]
        log_id = params["well_log_id"]
        rig_name = params["rig_name"]
        well_name = params["well_name"]


        # Create Rig and Well
        # Call WITSML Import
        # Redirect to well page

        if well_id.present? && wellbore_id.present? && log_id.present? && rig_name.present? && well_name.present?
            @job = Job.create_job well_name, rig_name, @witsml_server.company
            if @job.present?
                @witsml_server.import_well @job, well_id, wellbore_id, log_id
                redirect_to @job
            end
        else
            redirect_to wells_path
            return
        end

    end

end
