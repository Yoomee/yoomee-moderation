class CreateContentFlagTypes < ActiveRecord::Migration
  def self.up
    create_table :content_flag_types do |t|
      t.string :name
    end
  end

  def self.down
    drop_table :content_flag_types
  end
end
