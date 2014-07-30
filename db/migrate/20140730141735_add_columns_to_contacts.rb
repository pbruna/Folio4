class AddColumnsToContacts < ActiveRecord::Migration
  def change
    add_column :contacts, :mobile_phone, :string
    add_column :contacts, :title, :string
    add_column :contacts, :description, :text
  end
end