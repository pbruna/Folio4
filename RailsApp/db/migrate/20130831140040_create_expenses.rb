class CreateExpenses < ActiveRecord::Migration
  def change
    create_table :expenses do |t|
      t.integer  "account_id"

      t.timestamps
    end
    add_index :expenses, :account_id
  end
end
