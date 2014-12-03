class AddRecepFieldsToDte < ActiveRecord::Migration
  def change
    add_column :dtes, :giro_recep, :string, null: false
    add_column :dtes, :cmna_recep, :string, null: false
    add_column :dtes, :dir_recep, :string, null: false
  end
end