require File.dirname(__FILE__) + '/../test_helper'

class ContentFlagFieldTest < ActiveSupport::TestCase

  should have_db_column(:content_flag_id)
  should have_db_column(:name)
  should have_db_column(:value)
  should belong_to(:content_flag)
  should validate_presence_of(:name)
  
  context "a valid instance" do
    
    setup do
      @content_flag_field = Factory.build(:content_flag_field)
    end
    
    should "be valid" do
      @content_flag_field.valid?
      puts @content_flag_field.errors.full_messages
      assert @content_flag_field.valid?
    end
    
    should "save" do
      assert @content_flag_field.save
    end
    
  end

end
