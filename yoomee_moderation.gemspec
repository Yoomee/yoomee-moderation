# Provide a simple gemspec so you can easily use your enginex
# project in your rails apps through git.
Gem::Specification.new do |s|
  s.name = "yoomee-moderation"
  s.summary = "Gem for adding Yoomee's moderation tools to a site"
  s.description = ""
  s.files = Dir["{app,lib,config,db}/**/*"] + ["MIT-LICENSE", "Rakefile", "Gemfile", "README.rdoc"]
  s.version = "0.0.1"
  s.add_dependency("haml")
  s.add_dependency("googlecharts")
end