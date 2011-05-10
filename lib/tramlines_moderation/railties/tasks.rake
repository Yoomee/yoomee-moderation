namespace :tramlines_moderation do
  
  desc "Copy all migrations etc. into the application"
  task :install => :environment do
    system "cp  -rv #{File.dirname(__FILE__) + '/../../../db/migrate/*'} #{Rails.root}/db/migrate/"
  end
  
end