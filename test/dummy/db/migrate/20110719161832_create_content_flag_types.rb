class CreateContentFlagTypes < ActiveRecord::Migration
  def self.up
    create_table :content_flag_types do |t|
      t.string :name
      t.string :color, :default => "#2795E4"
    end
    ContentFlagType.create(:name => "Offensive language")
  end

  def self.down
    drop_table :content_flag_types
  end
end
