class ChangeDteProcessDefault < ActiveRecord::Migration
  def change
    change_column_default :dtes, :processed, false
  end
end