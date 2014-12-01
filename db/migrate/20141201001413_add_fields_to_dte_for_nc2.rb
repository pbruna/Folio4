class AddFieldsToDteForNc2 < ActiveRecord::Migration
  def change
    add_column :dtes, :folio_ref, :integer
    add_column :dtes, :fch_ref, :date
    add_column :dtes, :tpo_doc_ref, :integer
  end
end