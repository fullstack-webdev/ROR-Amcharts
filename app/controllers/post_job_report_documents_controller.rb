class PostJobReportDocumentsController < ApplicationController
    before_filter :signed_in_admin, only: [:create, :update, :destroy]

    def create


        document_id = params[:post_job_report_document][:document_id]
        params[:post_job_report_document].delete(:document_id)

        if document_id.to_i == -1
            render :nothing => true, :status => 200
            return
        elsif document_id.to_i == 0
            document = Document.new(name: "Report Part", category: Document::POST_JOB_REPORT_PART, template: true)
            document.company = current_user.company
            document.save
            document_id = document.id
        elsif document_id.to_i == -10
            document = Document.new(name: "Job Data", category: Document::POST_JOB_REPORT_PART, template: true)
            document.document_type = Document::CUSTOM_DATA
            document.company = current_user.company
            document.save
            document_id = document.id
        end

        @post_job_report_document = PostJobReportDocument.new(params[:post_job_report_document])
        @post_job_report_document.document = Document.find_by_id(document_id)
        not_found unless @post_job_report_document.document.company == current_user.company
        @post_job_report_document.company = current_user.company

        @post_job_report_document.save
    end

    def update
        @post_job_report_document = PostJobReportDocument.find_by_id(params[:id])
        not_found unless @post_job_report_document.document.company == current_user.company

        if params[:reorder].present?
            if params[:reorder] == "-1"
                if @post_job_report_document.ordering > 0
                    PostJobReportDocument.transaction do
                        @post_job_report_document.ordering -= 1
                        @post_job_report_document.save


                    end

                    @move_up = true

                    render 'post_job_report_documents/reorder'
                else
                    render :nothing => true, :status => :ok
                end
            end
        end
    end

    def destroy
        @post_job_report_document = PostJobReportDocument.find_by_id(params[:id])
        not_found unless @post_job_report_document.document.company == current_user.company

        if @post_job_report_document.document.category == Document::POST_JOB_REPORT_PART
            @post_job_report_document.document.destroy
        else
            @post_job_report_document.destroy
        end

    end

end
