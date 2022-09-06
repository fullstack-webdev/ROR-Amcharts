class DocumentsController < ApplicationController
    before_filter :signed_in_user, only: [:show, :new, :create, :update, :destroy]

    respond_to :js

    include JobLogHelper

    def show

        @document = Document.find(params[:id])
        not_found unless !@document.nil?

        respond_to do |format|
            format.html {
                not_found
            }
            format.xlsx {
                excel = nil
                case @document.document_type
                    when Document::JOB_LOG
                        excel = logs_to_excel(JobLog.where(:company_id => current_user.company_id).where(:document_id => @document.id).order("entry_at ASC"), @document)
                end
                if excel.present?
                    send_data excel.to_stream.read, :filename => "#{@document.name}.xlsx", :type => "application/vnd.openxmlformates-officedocument.spreadsheetml.sheet"
                end
            }
            format.js {
                if params[:reorder].present?
                    if params[:reorder] == "-1"
                        puts @document.ordering.to_s + "....................."
                        if @document.ordering > 0
                            Document.transaction do
                                @document.ordering -= 1
                                @document.save

                                @document.document_collection.each do |document|
                                    if document != @document and (document.ordering || 0) == @document.ordering
                                        document.ordering = (document.ordering || 0) + 1
                                        document.save
                                    end
                                end
                            end

                            @move_up = true

                            render 'documents/reorder'
                        else
                            render :nothing => true, :status => :ok
                        end
                    end
                end
            }
            format.xml {
                render xml: @document,
                       :methods => [:full_url, :upload_info],
                       include: {
                               :document_template => {
                                       :methods => :full_url,
                               },
                               :user => {except: [:created_at, :updated_at, :password_digest, :remember_token, :elephant_admin, :create_password]}
                       }
            }
        end
    end

    def new

        if params["modal"].present? && params["modal"] == "true"
            @job_id = params[:job_id]
            @document = Document.new
            render 'documents/new_modal'
        elsif params["multi"].present? && params["multi"] == "true"
            @document = Document.new
            @document.name = File.basename(params[:name], ".*" )
            if params[:name].length > 149
                @document.name = @document.name[0..149]
            end
            @document.company = current_user.company
            @document.job = Job.find_by_id(params[:job_id])
            @temp_id = params[:temp_id]
            @document.save
            render 'documents/create_multi'
        else
            @document = Document.new(params[:document])
            @filename ||= File.basename(@document.url)

            render 'documents/new'
        end

    end

    def create

        job_id = params[:document][:job_id]
        params[:document].delete(:job_id)

        owner_id = params[:document][:owner_id]
        params[:document].delete(:owner_id)

        owner_type = params[:document][:owner_type]
        params[:document].delete(:owner_type)

        @document = Document.new(params[:document])
        if @document.template?
            @document.access_level = 0
            if @document.document_type == Document::PROTECTED_DOCUMENT
                @document.document_type = Document::DOCUMENT
                @document.access_level = Document::DOCUMENT_RESTRICTED
            end
        end
        @document.company = current_user.company

        if @document.template?
            @document.ordering = @document.document_collection.count

            if !@document.save
                render 'error'
            end

            if @document.category == Document::NOTICES
                @document.delay.add_notices_on_active_jobs
            end

            Activity.delay.add(self.current_user, Activity::DOCUMENT_CREATED, @document, @document.name)
        else

            if job_id.present?
                @job = Job.find_by_id(job_id)
                not_found unless @job.company == current_user.company
                @document.job = @job
                @document.ordering = @document.document_collection.count
            elsif owner_id.present?
                owner = owner_type.constantize.find(owner_id)
                not_found unless owner.company == current_user.company
                @document.owner = owner
            end

            if @document.save
                render 'documents/create_modal'
            else
                render 'error'
            end

        end

    end

    def update
        @document = Document.find(params[:id])

        if @document.template?
            not_found unless signed_in_admin?
        end

        @document.user = current_user
        @document.user_name = current_user.name
        @document.url = params[:document][:url]

        if @document.template?
            @document.access_level = 0
            if params[:document][:document_type] == Document::PROTECTED_DOCUMENT
                @document.document_type = Document::DOCUMENT
                @document.access_level = Document::DOCUMENT_RESTRICTED
            end
        end

        @document.save

        if !@document.template?
            Activity.delay.add(current_user, Activity::DOCUMENT_UPLOADED, @document, @document.file_name, @document.job)
        end

        respond_to do |format|
            format.js {
                render 'documents/update'
            }
            format.xml { render xml: @document,
                                :methods => :full_url,
                                include: {
                                        :document_template => {
                                                :methods => :full_url,
                                        },
                                        :user => {except: [:created_at, :updated_at, :password_digest, :remember_token, :elephant_admin, :create_password]}
                                }
            }
        end
    end


    def destroy
        @document = Document.find(params[:id])
        not_found unless @document.company == current_user.company
        @document.delete_document
        @document.destroy

        if !@document.destroy
            render 'error'
        end

        #if @document.category == Document::NOTICES
        #    @document.delay.delete_notice_on_jobs @document.id
        #end

        @document.document_collection.each do |document|
            if document != @document and (document.ordering || 0) > @document.ordering
                document.ordering = (document.ordering || 0) - 1
                document.save
            end
        end

        Activity.delay.add(self.current_user, Activity::DOCUMENT_DESTROYED, @document, @document.name)

    end

end
