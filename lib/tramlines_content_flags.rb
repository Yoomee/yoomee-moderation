module TramlinesContentFlags
  
  def self.included(klass)
    Formtastic::SemanticFormBuilder.send(:include, TramlinesContentFilter::SemanticFormBuilderExtensions)
    User.send(:include, TramlinesContentFilter::UserExtensions)
    Notifier.send(:include, TramlinesContentFlags::NotifierExtensions)
  end
  
end
