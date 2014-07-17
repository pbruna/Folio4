class AddIndexToComments < ActiveRecord::Migration
  def change
    add_index :comments, :author_id
    add_index :comments, :author_type
    add_index :comments, :commentable_id
    add_index :comments, :commentable_type
  end
end