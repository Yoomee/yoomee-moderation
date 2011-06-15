class ContentFlagType < ActiveRecord::Base
  
  has_many :content_flaggings, :dependent => :destroy
  
  validates_presence_of :name, :color

  scope :ascend_by_name, :order => "content_flag_types.name ASC"

  def content_flags
    ContentFlag.for_type(self)
  end
  
  def unresolved_content_flag_count
    content_flags.unresolved.count(:select => "DISTINCT content_flags.id")
  end
  
  def hex_color
    color[1..6]
  end

  def to_s
    name
  end
    
end
