class AddUsers < ActiveRecord::Migration

  def self.up
    create_table :users do |t|
      t.string :name
      t.boolean :admin, :default => false
    end
  end

  def self.down
    drop_table :users
  end
  
end
