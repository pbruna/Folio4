class AddAccountIdToAttachment < ActiveRecord::Migration
  def change
    add_reference :attachments, :account, index: true
  end
end
