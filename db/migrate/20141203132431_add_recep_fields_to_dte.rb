class AddRecepFieldsToDte < ActiveRecord::Migration
  def change
    add_column :dtes, :giro_recep, :string
    add_column :dtes, :cmna_recep, :string
    add_column :dtes, :dir_recep, :string
  end
end