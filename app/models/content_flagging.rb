class ContentFlagging < ActiveRecord::Base

  belongs_to :user
  belongs_to :content_flag
  belongs_to :content_flag_type
  belongs_to :flagger, :class_name => "User", :foreign_key => "user_id"

  delegate :attachable, :has_attachable?, :to => :content_flag

  validates_format_of :email, :with => /^[^\s]+@[^\s]*\.[a-z]{2,}$/, :allow_blank => true
  validates_presence_of :content_flag_type_id, :message => "please select a reason why you are reporting this content"
  validates_presence_of :content_flag
  
  # for spam prevention
  attr_accessor :comment
  attr_writer :attachable_type, :attachable_id, :url
  validates_length_of :comment, :maximum => 0, :allow_nil => true, :message => "must be blank"

  before_create :create_content_flag_fields_and_unresolve
  before_validation :build_content_flag, :on => :create
  after_create :send_email

  scope :created_at_greater_than, lambda {|date| {:conditions => ["created_at > ?", date]}}
  scope :from_today, lambda {{:conditions => ["content_flaggings.created_at > ?", Date.today]}}
  scope :from_different_people, :group => "content_flaggings.ip_address, content_flaggings.user_id"

  class << self
    def last_month
      date = 27.days.ago.to_date
      by_flag_type = find(:all, :select => "count(*) AS count, content_flag_type_id, day(created_at) AS day", :group => "content_flag_type_id").group_by(&:day)

      flag_type_ids = ContentFlagType.all.collect(&:id)      
      flagging_data_sets = flag_type_ids.map{|i| []}

      days = []
      while date <= Date.today
        res = {}
        if day_res = by_flag_type[date.day]
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

  def attachable_type
    @attachable_type.try(:camelize) || content_flag.try(:attachable_type)
  end
  
  def attachable_id
    @attachable_id || content_flag.try(:attachable_id)
  end

  def url
    @url || content_flag.try(:url)
  end

  private
  def build_content_flag
    if !attachable_type.blank? && !attachable_id.blank?
      self.content_flag ||= ContentFlag.find_or_initialize_by_attachable_type_and_attachable_id(attachable_type, attachable_id)
    elsif !url.blank?
      self.content_flag ||= ContentFlag.find_or_initialize_by_url(url)
    end
  end
  
  def create_content_flag_fields_and_unresolve
    if has_attachable?
      attachable.class.columns.collect{|col|col.name if ([:text, :string].include?(col.type) && !col.name.match(/type$/))}.compact.each do |attribute|
        content_flag.create_content_flag_field_if_changed(attribute, attachable.send(attribute))
      end
      if attachable.respond_to?(:user_id) && attachable.user_id
        content_flag.create_content_flag_field_if_changed("user_id", attachable.user_id)
      end
    end
    content_flag.unresolve! if content_flag.resolved?
  end

  def send_email
    ContentFlaggingNotifier.delay.content_flagging_notification(self)
  end

end