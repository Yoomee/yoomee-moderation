class AddEmailToContentFlags < ActiveRecord::Migration
  def self.up
    add_column :content_flags, :email, :string
  end

  def self.down
    remove_column :content_flags, :email
  end
end
