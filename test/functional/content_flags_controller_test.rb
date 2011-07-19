require File.dirname(__FILE__) + '/../test_helper'

class ContentFlagsControllerTest < ActionController::TestCase
  
  context "index" do
    
    context "GET" do
      
      setup do
        get :index
      end
      
      should render_template("moderation/index")
      
    end


    context "AJAX GET" do
      
      setup do
        xhr :get, :index
      end
      
      should render_template("moderation/_dashboard")
      
    end
    
  end
  
  context "inbox" do
    
    context "AJAX GET" do
      
      setup do
        xhr :get, :inbox
      end
      
      should render_template("_content_flag_list")
      
    end
    
  end
  
  context "resolved" do
    
    context "AJAX GET" do
      
      setup do
        xhr :get, :resolved
      end
      
      should render_template("_content_flag_list")
      
    end
    
  end

end
