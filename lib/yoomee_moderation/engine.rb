require 'rails'
module YoomeeModeration
  
  class Engine < Rails::Engine
   
    rake_tasks do
      load "yoomee_moderation/railties/tasks.rake"
    end

    config.to_prepare do
      require 'googlecharts'
      require 'haml'
      require 'formtastic'
      User.send(:include, YoomeeContentFilter::UserExtensions)
    end
    
  end
  
end