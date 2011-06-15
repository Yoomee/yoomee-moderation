class ContentFlagging < ActiveRecord::Base

  belongs_to :user
  belongs_to :content_flag
  belongs_to :content_flag_type
  belongs_to :flagger, :class_name => "User", :foreign_key => "user_id"
  
  delegate :attachable, :has_attachable?, :to => :content_flag
  
  validates_format_of :email, :with => /^[^\s]+@[^\s]*\.[a-z]{2,}$/, :allow_blank => true
  validates_presence_of :content_flag_type_id, :message => "please give a reason why you are reporting this content"
  
  # for spam prevention
  attr_accessor :comment
  validates_length_of :comment, :maximum => 0, :allow_nil => true, :message => "must be blank"

  after_create :send_email
  before_create :create_content_flag_fields_and_unresolve
  after_create :auto_remove_content_flag

  scope :created_at_greater_than, lambda {|date| {:conditions => ["created_at > ?", date]}}
  scope :from_today, lambda {{:conditions => ["content_flaggings.created_at > ?", Date.today]}}
  scope :from_different_people, :group => "content_flaggings.ip_address, content_flaggings.user_id"
  scope :not_flagged_by_human, :conditions => {:flagged_by_human => false}
  
  class << self
    def last_month
      date = 27.days.ago.to_date
      by_flag_type = find(:all, :select => "count(*) AS count, content_flag_type_id, day(created_at) AS day", :group => "content_flag_type_id").group_by(&:day)
            
      flag_type_ids = ContentFlagType.all.collect(&:id)      
      flagging_data_sets = flag_type_ids.map{|i| []}
      
      days = []
      
      while date <= Date.today
        res = {}
        if day_res = by_flag_type[date.day.to_s]
          day_res.map{|r| res[r.content_flag_type_id] = r.count}
        end
        flag_type_ids.each_with_index{|fti, idx| flagging_data_sets[idx] << (res[fti] || 0).to_i}
        days << date.day.to_s
        date += 1.day
      end
      return days, flagging_data_sets
    end
    
    def last_month_max
      res = created_at_greater_than(27.days.ago.to_date).count(:group => "day(created_at)", :order => "count_all DESC")
      res.blank? ? 10 : res.to_a[0][1]
    end
    
    def flag_type_counts
      ret = []
      res = ContentFlagging.count(:group => :content_flag_type_id)
      ContentFlagType.all.each do |ft|
        ret << (res[ft.id] || 0)
      end
      ret
    end
    
  end
  
  private
  def auto_remove_content_flag
    content_flag.auto_remove_if_needed
  end
  
  def create_content_flag_fields_and_unresolve
    if flagged_by_human? && has_attachable?
      if attachable.class.respond_to?(:filtered_attributes)
        attachable.class.filtered_attributes.each do |attribute|
          content_flag.create_content_flag_field_if_changed(attribute, attachable.send(attribute))
        end
      else
        attachable.class.columns.collect{|col|col.name if ([:text, :string].include?(col.type) && !col.name.match(/type$/))}.compact.each do |attribute|
          content_flag.create_content_flag_field_if_changed(attribute, attachable.send(attribute))
        end
      end
      if attachable.respond_to?(:user_id) && attachable.user_id
        content_flag.create_content_flag_field_if_changed("user_id", attachable.user_id)
      end
    end
    content_flag.unresolve! if content_flag.resolved?
  end

  def send_email
    ContentFlaggingNotifier.content_flagging_notification(self).deliver
  end
  
end