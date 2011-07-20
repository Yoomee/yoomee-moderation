require File.dirname(__FILE__) + '/../test_helper'

class ContentFlagFieldTest < ActiveSupport::TestCase

  should have_db_column(:content_flag_id).of_type(:integer)
  should have_db_column(:name).of_type(:string)
  should have_db_column(:value).of_type(:text)
  should have_db_column(:created_at).of_type(:datetime)
  should have_db_column(:updated_at).of_type(:datetime)

  should belong_to(:content_flag)
  should validate_presence_of(:name)
  
  context "a valid instance" do
    
    setup do
      @content_flag_field = Factory.build(:content_flag_field)
    end
    
    should "be valid" do
      assert @content_flag_field.valid?
    end
    
    should "save" do
      assert @content_flag_field.save
    end
    
  end

end
