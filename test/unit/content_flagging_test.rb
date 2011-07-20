require File.dirname(__FILE__) + '/../test_helper'
class ContentFlaggingTest < ActiveSupport::TestCase

  should have_db_column(:content_flag_id).of_type(:integer)
  should have_db_column(:content_flag_type_id).of_type(:integer)
  should have_db_column(:user_id).of_type(:integer)
  should have_db_column(:message).of_type(:text)
  should have_db_column(:email).of_type(:string)
  should have_db_column(:ip_address).of_type(:string)
  should have_db_column(:created_at).of_type(:datetime)
  should have_db_column(:updated_at).of_type(:datetime)

  should belong_to(:user)
  should belong_to(:content_flag)
  should belong_to(:content_flag_type)
  should belong_to(:flagger)
  
  should validate_presence_of(:content_flag)
  should validate_presence_of(:content_flag_type_id).with_message("please select a reason why you are reporting this content")
  should validate_format_of(:email).with(/^[^\s]+@[^\s]*\.[a-z]{2,}$/)
    
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

  context "on create" do
    
    setup do
      @content_flagging = Factory.build(:content_flagging, :content_flag => nil)
    end
    
    should "create content_flag if one doesn't exist for attachable" do
      @asset = Factory.create(:asset, :id => 1)
      @content_flagging.attributes = {:attachable_type => "Asset", :attachable_id => 1}
      @content_flagging.save
      assert !@content_flagging.content_flag.new_record?
      assert_equal @content_flagging.content_flag.attachable, @asset
    end
    
    should "create content_flag if one doesn't exist for url" do
      @content_flagging.attributes = {:url => "http://www.example.com"}
      @content_flagging.save
      assert !@content_flagging.content_flag.new_record?
      assert_equal @content_flagging.content_flag.url, "http://www.example.com"
    end
    
    should "use existing content_flag for attachable" do
      @asset = Factory.create(:asset, :id => 1)
      @content_flag = Factory.create(:content_flag, :attachable => @asset)
      @content_flagging.attributes = {:attachable_type => "Asset", :attachable_id => 1}
      @content_flagging.save
      assert_equal @content_flagging.content_flag, @content_flag
    end
    
    should "use existing content_flag for url" do
      @content_flag = Factory.create(:content_flag, :url => "http://www.example.com")
      @content_flagging.attributes = {:url => "http://www.example.com"}
      @content_flagging.save
      assert_equal @content_flagging.content_flag, @content_flag
    end
    
    should "create an unresolved content_flag" do
      @content_flagging.attributes = {:url => "http://www.example.com"}
      @content_flagging.save
      assert !@content_flagging.content_flag.resolved?
    end
    
    should "set content flag to unresolved if already existed and was resolved" do
      @content_flag = Factory.create(:content_flag, :id => 1, :url => "http://www.example.com", :resolved_at => Time.now, :resolved_by_id => 1)
      @content_flagging.attributes = {:url => "http://www.example.com"}
      @content_flagging.save
      assert !ContentFlag.find(1).resolved?
    end
    
    context "saving content_flag_fields" do
      
      setup do
        @asset = Factory.create(:asset, :id => 1, :name => "Photo of a dog")
        @content_flag = Factory.create(:content_flag, :attachable => @asset)
        @content_flagging.content_flag = @content_flag
        @content_flagging.save
      end
    
      should "create content_flag_fields for attachable" do
        assert_equal @content_flagging.content_flag.content_flag_fields.collect(&:value), ["Photo of a dog"]
      end
    
      should "not create content_flag_fields on second flagging if asset is unchanged" do
        @second_content_flagging = Factory.create(:content_flagging, :content_flag => @content_flag)
        assert_equal @content_flagging.content_flag.content_flag_fields.collect(&:value), ["Photo of a dog"]
      end
      
      should "create content_flag_fields on second flagging if asset has changed" do
        @asset.name = "Photo of a cat"
        @second_content_flagging = Factory.create(:content_flagging, :content_flag => @content_flag)
        assert_equal @content_flagging.content_flag.content_flag_fields.collect(&:value).sort, ["Photo of a cat", "Photo of a dog"]
      end
    end
  end
end

