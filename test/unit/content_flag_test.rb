require File.dirname(__FILE__) + '/../test_helper'
class ContentFlagTest < ActiveSupport::TestCase

  should have_db_column(:attachable_id)
  should have_db_column(:attachable_type)
  should have_db_column(:created_at)
  should have_db_column(:updated_at)
  should have_db_column(:url)

  should belong_to(:attachable)
  should have_many(:content_flag_fields)
  should have_many(:content_flaggings)

    
  context "a valid instance" do
    
    setup do
      @content_flag = Factory.build(:content_flag)
    end
    
    should "be_valid" do
      assert_valid @content_flag
    end
    
  end

=begin  
  context "content is flagged by content filter" do

    setup do
      # Just in case they're changed by the client
      User.filtered_attributes.clear
      User.content_filter(:forename, :surname, :bio)
      User.class_eval do
        def forename;read_attribute(:forename);end
      end
      Factory.create(:content_filter_word)
      YoomeeContentFilter::flush_words!
      @user = Factory.create(:user, :forename => "fudge", :bio => "What the fudge?!", :acknowledged_failed_content_filter => true)
      @content_flag = ContentFlag.find_by_attachable_id_and_attachable_type(@user.id, "User")
    end
    
    should "create content flag" do
      assert !@content_flag.nil?
    end
    
    should "create filtered and unfiltered content flag fields for attributes that failed the filter" do
      assert_equal %w{bio bio forename forename}, @content_flag.content_flag_fields.collect(&:name).sort
    end

  end 
=end
end
