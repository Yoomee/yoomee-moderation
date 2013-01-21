module YoomeeModeration::UserExtensions
  
  def self.included(klass)
    # Flaggings that this user has raised
    klass.has_many :user_flaggings, :class_name => "ContentFlagging"
    klass.scope :top_flaggers, :select => "users.*, COUNT(content_flaggings.id) AS content_flaggings_count", :joins => "INNER JOIN content_flaggings ON (users.id = content_flaggings.user_id)", :group => "users.id", :order => "content_flaggings_count DESC"
    klass.scope :non_admin, :conditions => "role != 'admin'"
  end

end
