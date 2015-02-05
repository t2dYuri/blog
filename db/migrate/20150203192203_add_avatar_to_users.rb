class AddAvatarToUsers < ActiveRecord::Migration
  def change
    add_column :users, :avatar, :string
    add_column :users, :about_me, :string
    add_column :users, :birth_date, :datetime
  end
end
