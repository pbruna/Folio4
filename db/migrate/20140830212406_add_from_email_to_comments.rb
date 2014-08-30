class AddFromEmailToComments < ActiveRecord::Migration
  def change
    add_column :comments, :from_email, :boolean, default: false
  end
end