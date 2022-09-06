class ChangeUserRole < ActiveRecord::Migration
  def up
      remove_column :user_roles, :create_job
      remove_column :user_roles, :assign_users
      remove_column :user_roles, :district_read
      remove_column :user_roles, :district_modify
      remove_column :user_roles, :product_line_read
      remove_column :user_roles, :product_line_modify
      remove_column :user_roles, :global_read
      remove_column :user_roles, :global_modify
      remove_column :user_roles, :document_templates_modify

      add_column :user_roles, :role_id, :integer
  end

  def down
  end
end
