module YoomeeContentFlags
  
  def self.included(klass)
    Formtastic::SemanticFormBuilder.send(:include, YoomeeContentFilter::SemanticFormBuilderExtensions)
    User.send(:include, YoomeeContentFilter::UserExtensions)
    Notifier.send(:include, YoomeeContentFlags::NotifierExtensions)
  end
  
end
