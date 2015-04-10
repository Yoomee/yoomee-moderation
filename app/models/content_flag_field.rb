class ContentFlagField < ActiveRecord::Base

  belongs_to :content_flag
  validates_presence_of :name

  scope :latest, -> { order("created_at DESC") }
  scope :name_is, -> (name) { where(:name => name) }
  scope :name_is_not, -> (name) { where.not(:name => name) }

  def name=(val)
    val = val.to_s if val.is_a?(Symbol)
    write_attribute(:name, val)
  end

end
