class ProgramsController < ApplicationController
  autocomplete :well, :name
  # GET /programs
  # GET /programs.json
  def index
    @programs = Program.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @programs }
    end
  end

  # GET /programs/1
  # GET /programs/1.json
  def show
    @program = Program.includes(wells: :jobs).includes(wells: :rig).find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @program }
    end
  end

  # GET /programs/new
  # GET /programs/new.json
  def new
    @color_palette = ["#58c9c2", "#b858c9", "#589dc9", "#9babee", "#23c9ff", "#9aea6a", "#9eddde", "#987cf4", "#23fcff" ]
    @program = Program.new
    @jobs = current_user.jobs_list
    @jobs = Job.include_models(@jobs).includes(well: :drilling_log)

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @program }
    end
  end

  # GET /programs/1/edit
  def edit
    @color_palette = ["#58c9c2", "#b858c9", "#589dc9", "#9babee", "#23c9ff", "#9aea6a", "#9eddde", "#987cf4", "#23fcff" ]
    @program = Program.includes(:wells).find(params[:id])
    @jobs = current_user.jobs_list
    @jobs = Job.include_models(@jobs).includes(well: :drilling_log)

    puts "<<<<<<<<<<<<<<<"
    puts @program.inspect

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @program }
    end
  end

  # POST /programs
  # POST /programs.json
  def create
    @program = Program.new(params[:program])
    @program.name = params[:program_name]
    @program.company = current_user.company

    if params[:well_ids].present? && !params[:well_ids].split(",").empty?
      @program.wells << Well.find_all_by_id(params[:well_ids].split(",").reject! { |c| c.empty? }.map { |s| s.to_i })
    end

    respond_to do |format|
      if @program.save
        format.html { redirect_to wells_path + '#programs', notice: 'Program was successfully created.' }
        format.json { render json: @program, status: :created, location: @program }
      else
        format.html { render action: "new" }
        format.json { render json: @program.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /programs/1
  # PUT /programs/1.json
  def update
    @program = Program.find(params[:id])
    @program.name = params[:program_name]
    @program.wells.clear
    @program.wells << Well.find_all_by_id(params[:well_ids].split(",").select { |c| !c.empty? }.map { |s| s.to_i })

    puts "<<<<<<<<<<<<<<>>>>>>>>>>>>>>"
    puts @program.inspect

    puts "<<<<<<<<<<<<<<>>>>>>>>>>>>>>"
    puts params.inspect

    respond_to do |format|
      if @program.save
        format.html { redirect_to @program, notice: 'Program was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @program.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /programs/1
  # DELETE /programs/1.json
  def destroy
    @program = Program.find(params[:id])
    @program.destroy

    respond_to do |format|
      format.html { redirect_to programs_url }
      format.json { head :no_content }
    end
  end
end
