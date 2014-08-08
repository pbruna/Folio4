class RenameOpenDateToActiveDate < ActiveRecord::Migration
  def change
    rename_column :invoices, :open_date, :active_date
  end
end