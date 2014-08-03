class CreateAttachments < ActiveRecord::Migration
  def change
    create_table :attachments do |t|
      t.string :name
      t.string :category
      t.references :attachable, polymorphic: true

      t.timestamps
    end
    
    add_attachment :attachments, :resource
    
  end
end
