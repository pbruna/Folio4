class AddDteTestingToAccount < ActiveRecord::Migration
  def change
    add_column :accounts, :dte_testing, :boolean
    add_index :accounts, :dte_testing
  end
end