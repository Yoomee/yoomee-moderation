class CreateContentFlags < ActiveRecord::Migration
  
  def self.up
    create_table :content_flags do |t|
      t.string :url
      t.text :message
      t.belongs_to :attachable, :polymorphic => true
      t.belongs_to :user
      t.timestamps
    end
  end

  def self.down
    drop_table :content_flags
  end
  
end
