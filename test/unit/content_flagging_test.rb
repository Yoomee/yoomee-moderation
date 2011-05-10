require File.dirname(__FILE__) + '/../test_helper'
class ContentFlaggingTest < ActiveSupport::TestCase

  should have_db_column(:content_flag_id)
  should have_db_column(:content_flag_type_id)
  should have_db_column(:created_at)
  should have_db_column(:email)
  should have_db_column(:flagged_by_human).of_type(:boolean)
  should have_db_column(:user_id)
  should have_db_column(:message)
  should have_db_column(:updated_at)

  should belong_to(:content_flag)
  should belong_to(:content_flag_type)
  should belong_to(:user)
    
  context "a valid instance" do
    
    setup do
      @content_flagging = Factory.build(:content_flagging)
    end
    
    should "be_valid" do
      assert_valid @content_flagging
    end
    
  end
  
  context "an instance" do
    
    setup do
      @content_flagging = Factory.build(:content_flagging)
    end
    
    should "be valid if comment is blank" do
      @content_flagging.comment = ""
      assert_valid @content_flagging
    end
    
    should "be valid if comment is nil" do
      @content_flagging.comment = nil
      assert_valid @content_flagging
    end
    
    should "be invalid if comment is not blank" do
      @content_flagging.comment = "spam"
      assert !@content_flagging.valid?
    end
    
  end

  # TODO - we may want to implement filtered_attributes on User
  # context "content is flagged by human" do
  # 
  #   setup do
  #     @user = Factory.create(:user)
  #     @content_flag = Factory.create(:content_flag, :attachable => @user)
  #     @content_flagging = Factory.create(:content_flagging, :content_flag => @content_flag, :flagged_by_human => true)
  #   end
  #   
  #   should "create content flag fields for all filtered attributes" do
  #     assert_equal @content_flag.content_flag_fields.size, User.filtered_attributes.size
  #   end
  #   
  # end

end

