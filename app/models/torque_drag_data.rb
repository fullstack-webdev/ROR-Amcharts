class TorqueDragData < ActiveRecord::Base
  belongs_to :job
  belongs_to :company
  attr_accessible :entry_at, :file_name
end
