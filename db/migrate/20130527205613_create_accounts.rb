class CreateAccounts < ActiveRecord::Migration
  def change
    create_table :accounts do |t|
      t.string :name
      t.string :subdomain
      t.integer :owner_id
      t.integer :plan_id

      t.timestamps
    end
    
     add_index :accounts, :owner_id, :unique => true
     add_index :accounts, :plan_id
    
  end
end
