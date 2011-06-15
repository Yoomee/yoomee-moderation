namespace :yoomee_moderation do
  
  desc "Copy all migrations etc. into the application"
  task :install => :environment do
    system "cp  -rv #{File.dirname(__FILE__) + '/../../../db/migrate/*'} #{Rails.root}/db/migrate/"
    system "mkdir -p #{Rails.root}/public/yoomee_moderation"
    system "cp  -rv #{File.dirname(__FILE__) + '/../../assets/*'} #{Rails.root}/public/yoomee_moderation"
    system "cp  -rv #{File.dirname(__FILE__) + '/../../yoomee_moderation.yml'} #{Rails.root}/config"
  end
  
end