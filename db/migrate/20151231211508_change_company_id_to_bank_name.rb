class ChangeCompanyIdToBankName < ActiveRecord::Migration
  def change
    # remove_index :money_accounts, :company_id
    remove_column :money_accounts, :company_id
    # add_column :money_accounts, :bank_name, :string
  end
end
