class ContentFlag < ActiveRecord::Base

  belongs_to :attachable, :polymorphic => true
  belongs_to :resolved_by, :class_name => "User"
  before_create :set_opened_at
  
  has_many :content_flag_fields, :autosave => true, :dependent => :destroy
  has_many :content_flaggings, :dependent => :destroy
  has_many :content_flag_types, :through => :content_flaggings

  validates_presence_of :url, :unless => :has_attachable?

  scope :latest, :select => "content_flags.*, COUNT(content_flaggings.id) AS flagging_count", :joins => :content_flaggings, :group => "content_flags.id", :order => "flagging_count DESC, content_flags.opened_at DESC"
  scope :unresolved, :select => "DISTINCT content_flags.*", :joins => :content_flaggings, :conditions => "content_flags.resolved_at IS NULL"
  scope :resolved, :conditions => "content_flags.resolved_at IS NOT NULL"
  scope :for_type, lambda {|flag_type| {:select => "DISTINCT content_flags.*", :joins => :content_flaggings, :conditions => ["content_flaggings.content_flag_type_id = ?", flag_type.id]}}
  scope :ascend_by_resolved_at, :order => "content_flags.resolved_at ASC"
  scope :descend_by_resolved_at, :order => "content_flags.resolved_at DESC"
  scope :not_including, lambda {|content_flag| {:conditions => content_flag.nil? || content_flag.id.nil? ? "" : ["content_flags.id != ?", content_flag.id]}}
  
  class << self
    
    def average_response_in_seconds
      resolved.average("TIME_TO_SEC(TIMEDIFF(content_flags.resolved_at,content_flags.opened_at))").to_i
    end
    
    def average_response
      time = average_response_in_seconds
      return time, "second" if time < 600
      time = time/60
      return time, "minute" if time < 240
      time = time/60
      return time, "hour" if time < 24
      time = time/24
      return time, "day"
    end
    
    def unresolved_count
      unresolved.count(:id, :distinct => true)
    end
    
  end
  
  def create_content_flag_field_if_changed(attribute, value)
    latest_flag = content_flag_fields.name_is(attribute.to_s).latest.first
    if latest_flag.blank?
      content_flag_fields.create(:name => attribute.to_s, :value => value)
    elsif(latest_flag.value != value)
      content_flag_fields.create(:name => attribute.to_s, :value => value)
    end
  end

  def flagged_by_system?
    content_flaggings.not_flagged_by_human.count > 0
  end

  def has_attachable?
    !attachable.nil?
  end
  
  def history(field = nil)
    h = []
    h += content_flaggings
    if field && text_field
      h += content_flag_fields.name_is(text_field.name).name_is_not("user_id")
    else
      h += content_flag_fields.name_is_not("user_id")
    end
    h.sort{|x,y| y.created_at <=> x.created_at}
  end

  def user
    return nil if !has_attachable?
    if attachable.nil? && !(user_id_fields = content_flag_fields.name_is("user_id")).blank?
      User.find(user_id_fields.first.value)
    else
      attachable.respond_to?(:user) ? attachable.user : nil
    end
  end
  
  def user_full_name
    user.nil? ? nil : user.full_name
  end

  def name
    if user
      has_attachable? ? "#{user.full_name}'s #{attachable_type.downcase}" : user.full_name
    elsif has_attachable?
      "A #{attachable_type.downcase}"
    else
      APP_CONFIG['site_url'] + url
    end
  end
  alias_method :to_s, :name
  
  def next(options = {})
    if options[:menu_item]=="resolved"
      return ContentFlag.resolved.descend_by_resolved_at.find(:first, :conditions => ["content_flags.resolved_at < ?", resolved_at])
    end
    content_flag_type = ContentFlagType.find_by_id(options[:content_flag_type_id])
    next_content_flags = content_flag_type.nil? ? ContentFlag : content_flag_type.content_flags
    next_content_flags.unresolved.latest.not_including(self).find(:first, :group => "content_flags.id HAVING IF(flagging_count = #{content_flaggings.count}, content_flags.opened_at < '#{opened_at}', flagging_count < #{content_flaggings.count})")
  end
  
  def prev(options = {})
    if options[:menu_item]=="resolved"
      return ContentFlag.resolved.ascend_by_resolved_at.find(:first, :conditions => ["content_flags.resolved_at > ?", resolved_at])
    end
    content_flag_type = ContentFlagType.find_by_id(options[:content_flag_type_id])
    prev_content_flags = content_flag_type.nil? ? ContentFlag : content_flag_type.content_flags
    prev_content_flags.unresolved.latest.not_including(self).find(:first, :group => "content_flags.id HAVING IF(flagging_count = #{content_flaggings.count}, content_flags.opened_at > '#{opened_at}', flagging_count > #{content_flaggings.count})", :order => "flagging_count ASC, content_flags.opened_at ASC")
  end
  
  def text_field
    if has_attachable?
      text_fields = content_flag_fields.reject{|f| ["user_id","attachable_type"].include?(f.name)}
      if !text_fields.blank?
        if !(t = text_fields.select{|f| f.name == "text"}).blank?
          t.first
        else
          text_fields.first
        end
      end      
    end
  end
  
  def current_text
    if text_field
      attachable.send(text_field.name)
    end
  end
  
  def removable?
    return false if !has_attachable?
    attachable.respond_to?(:removed?)
  end
  
  def removed?
    removable? && attachable.removed?
  end
  
  def auto_removed?
    removed? && attachable.removed_by.nil?
  end
  
  def auto_remove!
    return false if !removable?
    attachable.update_attributes(:removed_at => Time.now, :removed_by => nil)
  end
  
  def auto_remove_if_needed
    return true if !removable?
    if content_flaggings.from_today.from_different_people.length == (APP_CONFIG['flagging_threshold'] || 3)
      auto_remove!
    else
      true
    end
  end
  
  def resolve!(user)
    return nil if user.nil?
    self.update_attributes(:resolved_by => user, :resolved_at => Time.now)
  end
  
  def unresolve!
    self.update_attributes(:resolved_by => nil, :resolved_at => nil, :opened_at => Time.now)
  end
  
  def resolved
    !resolved_at.blank?
  end
  alias_method :resolved?, :resolved

  def text
    text_field ? text_field.value : nil
  end

  def validate_attachable
    if has_attachable?
      attachable.content_filter_valid?
    end
  end
  
  
  private
  def set_opened_at
    self.opened_at = Time.now
  end

end
