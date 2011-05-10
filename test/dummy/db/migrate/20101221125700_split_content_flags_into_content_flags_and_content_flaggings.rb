class SplitContentFlagsIntoContentFlagsAndContentFlaggings < ActiveRecord::Migration
  def self.up
    create_table :content_flaggings do |t|
      t.belongs_to :content_flag
      t.belongs_to :content_flag_type
      t.boolean :flagged_by_human, :default => false
      t.belongs_to :user
      t.text :message
      t.string :email
      t.timestamps
    end
    
    remove_column :content_flags, :content_flag_type_id
    remove_column :content_flags, :flagged_by_human
    remove_column :content_flags, :user_id
    remove_column :content_flags, :message
    remove_column :content_flags, :email
    
    add_column :content_flag_fields, :created_at, :datetime
    add_column :content_flag_fields, :updated_at, :datetime
  end

  def self.down
    
    remove_column :content_flag_fields, :created_at, :datetime
    remove_column :content_flag_fields, :updated_at, :datetime
    
    add_column :content_flags, :content_flag_type_id, :integer
    add_column :content_flags, :flagged_by_human, :boolean, :default => false
    add_column :content_flags, :user_id, :integer
    add_column :content_flags, :message, :text
    add_column :content_flags, :email, :string
    
    drop_table :content_flaggings
  end
end
