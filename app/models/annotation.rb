class Annotation < ActiveRecord::Base
    attr_accessible :end_depth,
                    :end_time,
                    :start_depth,
                    :start_time,
                    :title


    acts_as_tenant(:company)

    validates_presence_of :company
    validates_presence_of :job

    belongs_to :company
    belongs_to :job

    belongs_to :user
    belongs_to :company_feature
    belongs_to :event_warning
    has_many :annotation_comments, :dependent => :destroy, order: "created_at ASC"

    def description
        self.annotation_comments.any? ? self.annotation_comments.first.text : ''
    end

end
