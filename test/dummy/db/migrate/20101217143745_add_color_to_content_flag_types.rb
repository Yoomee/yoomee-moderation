class AddColorToContentFlagTypes < ActiveRecord::Migration
  
  def self.up
    add_column :content_flag_types, :color, :string, :default => "#2795E4"
  end

  def self.down
    remove_column :content_flag_types, :color
  end
  
end
