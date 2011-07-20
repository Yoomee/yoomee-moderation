require File.dirname(__FILE__) + '/../test_helper'

class ContentFlagTypeTest < ActiveSupport::TestCase

  should have_db_column(:name).of_type(:string)
  should have_db_column(:color).of_type(:string)
  
  should have_many(:content_flaggings)
  
  should validate_presence_of(:name)
  should validate_presence_of(:color)  
  
  context "a valid instance" do
    
    setup do
      @content_flag_type = Factory.build(:content_flag_type)
    end
    
    should "be_valid" do
      assert_valid @content_flag_type
    end
    
  end

end
