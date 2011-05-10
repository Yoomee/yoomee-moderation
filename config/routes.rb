ActionController::Routing::Routes.draw do |map|

  namespace :moderation, :module => nil do
    #resources :content_flags, :member => {:remove => :delete, :resolve => :put, :restore => :put, :unresolve => :put}, :collection => {:resolved => :get, :inbox => :get}
    resources :content_flags do
      collection do
        get :inbox
        get :resolved
      end
    end
    resources :content_flaggings
    resources :content_flag_types
    map.moderation "/moderation/content_flags", :controller => "content_flags"
  end
  
  map.connect ":attachable_type/:attachable_id/content_flaggings/new", :controller => "content_flaggings", :action => "new"

end