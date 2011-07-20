require File.dirname(__FILE__) + '/../test_helper'

class ContentFlagTest < ActiveSupport::TestCase

  should have_db_column(:url).of_type(:string)
  should have_db_column(:attachable_id).of_type(:integer)
  should have_db_column(:attachable_type).of_type(:string)
  should have_db_column(:resolved_by_id).of_type(:integer)
  should have_db_column(:resolved_at).of_type(:datetime)
  should have_db_column(:opened_at).of_type(:datetime)
  should have_db_column(:created_at).of_type(:datetime)
  should have_db_column(:updated_at).of_type(:datetime)

  should belong_to(:attachable)
  should belong_to(:resolved_by)
  
  should have_many(:content_flag_fields).dependent(:destroy)
  should have_many(:content_flaggings).dependent(:destroy)
  should have_many(:content_flag_types).through(:content_flaggings)
  
  should validate_presence_of(:url)
  
  context "a valid instance" do
    
    setup do
      @content_flag = Factory.build(:content_flag)
    end
    
    should "be valid" do
      assert @content_flag.valid?
    end
    
    should "save" do
      assert @content_flag.save
    end
    
  end

end
