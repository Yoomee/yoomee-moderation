namespace :yoomee_moderation do
  
  desc "Copy all migrations etc. into the application"
  task :install => :environment do
    copy_migrations
    copy_assets
    copy_yaml_file
  end
  
  private  
  def copy_assets
    added_or_updated = File.exists?("#{Rails.root}/public/yoomee_moderation") ? "Updated" : "Added"    
    system "mkdir -p #{Rails.root}/public/yoomee_moderation"
    assets_path = File.dirname(__FILE__) + '/../../assets/'
    if system "cp -r #{assets_path}* #{Rails.root}/public/yoomee_moderation"
      puts "#{added_or_updated} the following assets:"
      Dir["#{assets_path}*"].each do |path|
        path.gsub!(assets_path, '')
        puts "  public/yoomee_moderation/#{path}"
      end
    end  
  end
  
  def copy_migrations
    migrations_added = []
    Dir[File.dirname(__FILE__) + '/../../../db/migrate/*'].each_with_index do |full_filename, i|
      filename = full_filename.gsub(File.dirname(__FILE__) + '/../../../db/migrate/', '')
      if !migration_exists?(filename)
        new_filename = "#{i.seconds.from_now.strftime("%Y%m%d%k%M%S")}_#{filename.gsub(/^\d+_/, '')}"
        if system "cp -r #{full_filename} #{Rails.root}/db/migrate/#{new_filename}"
          migrations_added << new_filename
        end
      end
    end
    if !migrations_added.empty?
      puts "Added the following migrations:"
      migrations_added.each do |filename|
        puts "  db/migrate/#{filename}"
      end
    end
  end
  
  def copy_yaml_file
    if !File.exists?("#{Rails.root}/config/yoomee_moderation.yml")
      if system "cp  -r #{File.dirname(__FILE__) + '/../../yoomee_moderation.yml'} #{Rails.root}/config"
        puts "Added a default config file for you to edit:"
        puts "  config/yoomee_moderation.yml"
      end
    end  
  end
  
  def migration_exists?(filename)
    !Dir["#{Rails.root}/db/migrate/*_#{filename.gsub(/^\d+_/, '')}"].empty?
  end
  
end