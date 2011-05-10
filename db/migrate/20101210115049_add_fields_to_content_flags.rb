class AddFieldsToContentFlags < ActiveRecord::Migration
  def self.up
    add_column :content_flags, :content_flag_type_id, :integer
    add_column :content_flags, :flagged_by_human, :boolean, :default => false
  end

  def self.down
    remove_column :content_flags, :content_flag_type_id
    remove_column :content_flags, :flagged_by_human
  end
end
