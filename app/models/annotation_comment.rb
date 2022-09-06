class AnnotationComment < ActiveRecord::Base
    attr_accessible :text

    acts_as_tenant(:company)

    validates_presence_of :company

    belongs_to :company
    belongs_to :annotation
    belongs_to :user

end
