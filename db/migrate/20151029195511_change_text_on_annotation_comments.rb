class ChangeTextOnAnnotationComments < ActiveRecord::Migration
  def change
      change_column :annotation_comments, :text, :text
  end

end
