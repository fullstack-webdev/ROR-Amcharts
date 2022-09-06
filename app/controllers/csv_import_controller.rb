class CsvImportController < ApplicationController
  before_filter :signed_in_admin
  layout 'admin'
  set_tab :csv_import

  def index
    company_id = params[:id]

    @companies = Company.all
    @company = @companies.first
    if company_id != nil && company_id != '' && Company.exists?(company_id)
      @company = Company.find(company_id)
    end

    current_user.company_id = company_id

    @files = Array.new
    Dir.glob("public/csvs/*.csv") do |text_file|
      @files << File.basename(text_file)
    end
  end

  def import
    filename = params[:filename]

  end
end
