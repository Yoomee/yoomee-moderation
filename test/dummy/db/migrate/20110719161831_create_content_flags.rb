class CreateContentFlags < ActiveRecord::Migration
  
  def self.up
    create_table :content_flags do |t|
      t.string :url
      t.belongs_to :attachable, :polymorphic => true
      t.integer :resolved_by_id
      t.datetime :resolved_at
      t.datetime :opened_at
      t.timestamps
    end
    
  end

  def self.down
    drop_table :content_flags
  end
  
end
