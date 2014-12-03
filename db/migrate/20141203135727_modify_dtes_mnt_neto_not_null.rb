class ModifyDtesMntNetoNotNull < ActiveRecord::Migration
  def change
    change_column :dtes, :mnt_neto, :integer, default: nil, null: true
  end
end