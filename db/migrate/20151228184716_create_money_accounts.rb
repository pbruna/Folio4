class CreateMoneyAccounts < ActiveRecord::Migration
  def change
    create_table :money_accounts do |t|
      t.string 'name'
      t.integer 'account_id'
      t.string 'number'
      t.string 'description'
      t.string 'bank_name'
      t.integer 'type_id'
      t.integer 'total_credit_clp', default: 0
      t.integer 'total_credit_usd', default: 0

      t.timestamps
    end
    add_index :money_accounts, :account_id
    add_index :money_accounts, :type_id
  end
end
