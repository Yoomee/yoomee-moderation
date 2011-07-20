require File.dirname(__FILE__) + '/../test_helper'

class ContentFlaggingsControllerTest < ActionController::TestCase
  
  context "new" do
    setup do
      xhr :get, :new
    end    
    should render_template("content_flaggings/_form")
  end
  
  context "create" do
    setup do
      @controller.stubs(:current_user).returns(Factory.create(:user))
      xhr :post, :create, :content_flagging => {:url => "http://www.example.com"}
    end
    should respond_with(:success)
  end

end
