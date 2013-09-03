class CreateAudits < ActiveRecord::Migration
  def change
    create_table :audits do |t|
      t.integer :account_id
      t.integer :user_id

      t.timestamps
    end
    
    add_index :audits, :account_id
    add_index :audits, :user_id
  end
end
