class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.string :subject
      t.text :message
      t.references :commentable, polymorphic: true
      t.references :author, polymorphic: true

      t.timestamps
    end
  end
end