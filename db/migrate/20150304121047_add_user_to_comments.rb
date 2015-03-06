class AddUserToComments < ActiveRecord::Migration
  def change
    add_reference :comments, :user, index: true
    add_foreign_key :comments, :users
    add_index :comments, [:user_id, :created_at]
    remove_column :comments, :commenter
  end
end
