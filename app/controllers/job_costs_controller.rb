class JobCostsController < ApplicationController
    before_filter :signed_in_user, only: [:index, :show, :new, :create, :edit, :update, :destroy]

    include JobCostsHelper

    def index
        @job = Job.find_by_id(params[:job])
        not_found unless @job.present?

        respond_to do |format|
            format.html {
            }
            format.js {
            }
            format.xlsx {
                excel = job_costs_to_excel @job
                send_data excel.to_stream.read, :filename => "Costs - #{@job.name}.xlsx", :type => "application/vnd.openxmlformates-officedocument.spreadsheetml.sheet"
            }
        end
    end

    def show

    end

    def new

    end

    def create
        job_id = params[:job_cost][:job_id]
        params[:job_cost].delete(:job_id)
        @job = Job.find_by_id(job_id)

        charge_at = params[:job_cost][:charge_at]
        params[:job_cost].delete(:charge_at)

        price = params[:job_cost][:price]
        params[:job_cost].delete(:price)

        @job_cost = JobCost.new(params[:job_cost])
        @job_cost.company = current_user.company
        @job_cost.user = current_user
        @job_cost.job = @job
        @job_cost.price = price.to_s.gsub(/,/, '').to_f
        date = Date.strptime("#{charge_at}", '%m/%d/%Y')
        @job_cost.charge_at = Time.zone.parse("#{date.year}-#{date.month}-#{date.day}")
    end

    def edit

    end

    def update

    end

    def destroy
        @job_cost = JobCost.find_by_id(params[:id])
        @job = @job_cost.job
        not_found unless @job_cost.present?
        @job_cost.destroy
    end

end
