Rails.application.routes.draw do

  namespace :moderation, :module => nil do
    resources :content_flags do
      member do
        put :resolve
        put :unresolve
      end
      collection do
        get :inbox
        get :resolved
      end
    end
    resources :content_flaggings
    resources :content_flag_types

  end
  get '/moderation(/home)', :to => 'content_flags#index', :as => 'moderation'

  get ":attachable_type/:attachable_id/content_flaggings/new", :to => 'content_flaggings#new'

end