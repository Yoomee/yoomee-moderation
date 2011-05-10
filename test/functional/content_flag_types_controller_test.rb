require File.dirname(__FILE__) + '/../test_helper'

class ContentFlagTypesControllerTest < ActionController::TestCase

  context "index" do
    
    context "GET" do
      
      setup do
        get :index
      end
      
      should render_template("content_flag_types/index")
      
    end


    context "AJAX GET" do
      
      setup do
        xhr :get, :index
      end
      
      should render_template("content_flag_types/_content_flag_types_list")
      
    end
    
  end

end
