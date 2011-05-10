class AddOpenedAtToContentFlags < ActiveRecord::Migration
  def self.up
    add_column :content_flags, :opened_at, :datetime
  end

  def self.down
    remove_column :content_flags, :opened_at
  end
end
