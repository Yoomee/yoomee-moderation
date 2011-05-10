module TramlinesContentFilter::UserExtensions
  
  def self.included(klass)
    #klass.content_filter(:forename, :surname, :bio)
    # Flaggings that this user has raised
    klass.has_many :user_flaggings, :class_name => "ContentFlagging"
    klass.scope :top_flaggers, :select => "users.*, COUNT(content_flaggings.id) AS content_flaggings_count", :joins => "INNER JOIN content_flaggings ON (users.id = content_flaggings.user_id)", :group => "users.id", :order => "content_flaggings_count DESC"
    klass.scope :non_admin, :conditions => {:admin => false}
    # TODO - this currently only works on the basis of Shouts
    #klass.scope :most_flagged, :select => "users.*, COUNT(DISTINCT content_flaggings.id) AS flag_count", :joins => "INNER JOIN shouts ON (shouts.user_id = users.id) INNER JOIN wall_posts ON (wall_posts.user_id = users.id) INNER JOIN content_flags ON ((content_flags.attachable_type = 'Shout' AND content_flags.attachable_id = shouts.id) OR (content_flags.attachable_type = 'WallPost' AND content_flags.attachable_id = wall_posts.id)) INNER JOIN content_flaggings ON (content_flaggings.content_flag_id = content_flags.id)", :group => "users.id", :order => "flag_count DESC"
  end

end
