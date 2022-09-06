class RigMembership < ActiveRecord::Base
  attr_accessible :user_name


  acts_as_tenant(:company)

  after_save :after_save
  after_destroy :after_destroy

  belongs_to :user
  belongs_to :rig
  belongs_to :company

  validates :user, presence: true
  validates :rig, presence: true


private
  def after_save
      update_counter_cache
  end

  def after_destroy
      update_counter_cache
  end

  def update_counter_cache
      self.rig.rig_memberships_count = self.rig.rig_memberships.count()
      self.rig.save
  end
end
