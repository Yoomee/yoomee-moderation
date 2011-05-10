require 'rails'
module TramlinesModeration
  
  class Engine < Rails::Engine
   
    rake_tasks do
      load "tramlines_moderation/railties/tasks.rake"
    end

    config.to_prepare do
      require 'googlecharts'
      require 'haml'
      User.send(:include, TramlinesContentFilter::UserExtensions)
    end
    
  end
  
end