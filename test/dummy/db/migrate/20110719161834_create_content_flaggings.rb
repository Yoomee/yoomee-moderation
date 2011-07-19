class CreateContentFlaggings < ActiveRecord::Migration
  
  def self.up
    create_table :content_flaggings do |t|
      t.belongs_to :content_flag
      t.belongs_to :content_flag_type
      t.belongs_to :user
      t.text :message
      t.string :email
      t.string :ip_address
      t.timestamps
    end
  end

  def self.down
    drop_table :content_flaggings
  end
  
end