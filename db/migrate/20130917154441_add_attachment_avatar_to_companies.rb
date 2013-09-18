class AddAttachmentAvatarToCompanies < ActiveRecord::Migration
  def self.up
    change_table :companies do |t|
      t.attachment :avatar
    end
  end

  def self.down
    drop_attached_file :companies, :avatar
  end
end
