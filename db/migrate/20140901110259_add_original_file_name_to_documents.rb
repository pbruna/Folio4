class AddOriginalFileNameToDocuments < ActiveRecord::Migration
  def change
    add_column :attachments, :original_file_name, :string
  end
end