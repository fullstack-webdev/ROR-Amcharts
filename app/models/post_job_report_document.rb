class PostJobReportDocument < ActiveRecord::Base
    attr_accessible :ordering

    acts_as_tenant(:company)

    validates_uniqueness_of :document_id

    belongs_to :document
    belongs_to :job_template
    belongs_to :company

end
