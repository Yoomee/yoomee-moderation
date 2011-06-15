yaml_file = "#{RAILS_ROOT}/config/yoomee_moderation.yml"
if File.exists?(yaml_file)
  app_config = HashWithIndifferentAccess.new(YAML.load_file(yaml_file))
  app_config.merge!(app_config[RAILS_ENV]) if app_config.key?(RAILS_ENV) 
else
  puts "WARNING: config/yoomee_moderation.yml does not exist."
  app_config = {}
end

APP_CONFIG = app_config