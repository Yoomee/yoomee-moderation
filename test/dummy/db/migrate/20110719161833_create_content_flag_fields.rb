class CreateContentFlagFields < ActiveRecord::Migration
  def self.up
    create_table :content_flag_fields do |t|
      t.integer :content_flag_id
      t.string :name
      t.text :value
      t.timestamps
    end
  end

  def self.down
    drop_table :content_flag_fields
  end
end
