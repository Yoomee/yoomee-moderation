class AddResolvedFieldsToContentFlags < ActiveRecord::Migration
  def self.up
    add_column :content_flags, :resolved_by_id, :integer
    add_column :content_flags, :resolved_at, :datetime
  end

  def self.down                               
    remove_column :content_flags, :resolved_by_id
    remove_column :content_flags, :resolved_at
  end                                         
end
