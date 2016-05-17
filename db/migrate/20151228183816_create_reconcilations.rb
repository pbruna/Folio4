class CreateReconcilations < ActiveRecord::Migration
  def change
    create_table :reconcilations do |t|
      t.decimal "debit", precision: 10, scale: 0, default: 0
      t.decimal 'debt', precision: 10, scale: 0, default: 0
      t.string 'currency', default: 'clp'
      t.integer 'user_id', null: false
      t.integer 'money_account_id', null: false
            
      t.timestamps
    end
    add_index :reconcilations, :user_id
    add_index :reconcilations, :currency
    add_index :reconcilations, :money_account_id
  end
end