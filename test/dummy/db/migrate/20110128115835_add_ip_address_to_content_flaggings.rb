class AddIpAddressToContentFlaggings < ActiveRecord::Migration
  def self.up
    add_column :content_flaggings, :ip_address, :string
  end

  def self.down
    remove_column :content_flaggings, :ip_address
  end
end
