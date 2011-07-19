yaml_file = "#{Rails.root}/config/yoomee_moderation.yml"
if File.exists?(yaml_file)
  app_config = HashWithIndifferentAccess.new(YAML.load_file(yaml_file))
  app_config.merge!(app_config[Rails.env]) if app_config.key?(Rails.env) 
else
  puts "WARNING: config/yoomee_moderation.yml does not exist. Run rake yoomee_moderation:install"
  app_config = {}
end

APP_CONFIG = app_config