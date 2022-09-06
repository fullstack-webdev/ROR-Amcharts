class AddPhoneNumberToJobMemberships < ActiveRecord::Migration
  def change
    add_column :job_memberships, :phone_number, :string
    add_column :job_memberships, :email, :string
  end
end
