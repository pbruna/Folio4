class AddAuthorPolymorphicToAttachment < ActiveRecord::Migration
  def change
    add_reference :attachments, :author, index: true, polymorphic: true
  end
end
