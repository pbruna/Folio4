class ChangeDefaultsOfDteMnt < ActiveRecord::Migration
  def change
    change_column_default :dtes, :mnt_neto, 0
    change_column_default :dtes, :mnt_exe, 0
    change_column_default :dtes, :mnt_total, 0
  end
end