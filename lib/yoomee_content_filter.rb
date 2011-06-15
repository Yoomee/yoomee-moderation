module YoomeeContentFilter
  
  EXCERPT_PADDING = 20
  
  def self.included(klass)
    klass.validate :content_must_pass_filter
    klass.class_inheritable_array :filtered_attributes
    klass.alias_method_chain :valid?, :content_filter
    klass.before_save :star_out_filtered_words
    klass.before_update :create_or_update_content_flag_fields
    klass.after_save :create_content_flagging
    klass.has_one :content_flag, :as => :attachable, :dependent => :destroy
    klass.has_many :content_flaggings, :through => :content_flag
  end
  
  class << self
    
    def content_filter_words
      if ContentFilterWord::column_names.include?('whitelist')
        if @content_filter_words.nil?
          words = {}
          ContentFilterWord.blacklist.each do |word|
            ([word.word] + word.word.downcase.inflections).uniq.each do |inf|
              words[inf] = word.id
            end
          end
          ContentFilterWord.whitelist.collect{|w| w.word.downcase}.each do |word|
            words[word].delete
          end
          @content_filter_words = words
        else
          @content_filter_words
        end
      else
        # For initial migration
        []
      end
    end
    
    def filter_text(text, options={})
      local_filtered_words = []
      unfiltered_text, filtered_text = text, text.dup
      unfiltered_text.split_with_index(/[^\w]/).each do |word,index|
        if content_filter_words.keys.include?(word.downcase)
          local_filtered_words << [word, index]
          word_range = (index..index + word.length - 1)
          filtered_text[word_range] = filtered_text[word_range].gsub(/[aeiou]/i, '*')
          # ContentFilterWord.find(content_filter_words[word]).increment! #TODO This gets rolled back!
        end
      end

      return nil if local_filtered_words.blank?

      details = {:unfiltered => text, :starred => filtered_text, :words => local_filtered_words, :excerpts => words_in_context(unfiltered_text, local_filtered_words)}
    end
    
    def flush_words!
      @content_filter_words = nil
    end
    
    def group_by_proximity(words)
      returning out = [] do
        group = []
        words.each_with_index do |word, index|
          if word != words.last && words[index + 1][1] - word[1] <= EXCERPT_PADDING*2
            group << word
          else
            out << (group << word)
            group = []
          end
        end
      end
    end
    
    def pos(num)
      num < 0 ? 0 : num
    end
    
    def words_in_context(text, words_with_indices)
      returning ret = [] do
        group_by_proximity(words_with_indices).each do |group_of_words|
          excerpt = ""
          group_of_words.each_with_index do |word_with_index, group_index|
            word, index = word_with_index
            if group_index == 0 && !index.zero?
              excerpt += (index - EXCERPT_PADDING <= 0 ? text[0..pos(index-1)] : "..." + text[index-EXCERPT_PADDING..index-1])
            end
            excerpt += "<span class='filtered_word'>#{word}</span>"
            if word_with_index == group_of_words.last
              excerpt += (index + word.length + EXCERPT_PADDING >= text.length ? text[index + word.length..text.length] : text[index + word.length..index + word.length + EXCERPT_PADDING] + "...")
            else
              excerpt += text[index + word.length..group_of_words[group_index + 1][1] - 1]
            end
          end
          ret << excerpt
        end
      end
    end

  end
  
  def acknowledged_failed_content_filter
    Module.value_to_boolean(@acknowledged_failed_content_filter)
  end
  alias_method :acknowledged_failed_content_filter?, :acknowledged_failed_content_filter
  
  def acknowledged_failed_content_filter=(val)
    @acknowledged_failed_content_filter = Module.value_to_boolean(val)
  end
  
  def content_filter_errors
    @content_filter_errors ||= ActiveRecord::Errors.new(self)
  end
  
  def content_filter_valid?
    content_filter_errors.clear
    content_must_pass_filter
    content_filter_errors.empty?
  end
  
  def skip_content_filter
    Module.value_to_boolean(@skip_content_filter)
  end
  alias_method :skip_content_filter?, :skip_content_filter
  
  def skip_content_filter=(val)
    @skip_content_filter = Module.value_to_boolean(val)
  end

  def valid_with_content_filter?
    valid_without_content_filter? && (acknowledged_failed_content_filter? || content_filter_errors.empty?)
  end
  
  protected
  def content_must_pass_filter
    return true if skip_content_filter? || YoomeeContentFilter::content_filter_words.blank?
    content_filter_errors.clear
    self.class.filtered_attributes.each do |attr_name|
      filter_attribute(attr_name)
    end
  end
  
  private
  def create_content_flagging
    if !content_filter_errors.blank?
      content_flag = ContentFlag.find_or_create_by_attachable_type_and_attachable_id(self.class.to_s, self.id)
      content_flag.content_flaggings.create(:content_flag_type => ContentFlagType.find_or_create_by_name("Offensive language"))
      filtered_attributes = self.class::filtered_attributes.dup
      content_filter_errors.each_error do |attribute, error|
        content_flag.create_content_flag_field_if_changed(attribute, error.options[:unfiltered])
        filtered_attributes.delete(attribute)
      end
      content_filter_errors.each do |attribute, error|
        content_flag.create_content_flag_field_if_changed(attribute, send(attribute))
      end
      content_filter_errors.clear
    end
  end

  def create_or_update_content_flag_fields
    return true if content_flag.nil? || ["ContentFlagField", "ContentFlagging"].include?(self.class.to_s)
    self.class::filtered_attributes.each do |attribute|
      content_flag.create_content_flag_field_if_changed(attribute, send(attribute))
    end
    if self.respond_to?(:user_id) && !user_id.blank?
      content_flag.create_content_flag_field_if_changed("user_id", user_id)
    end
  end
  
  def filter_attribute(attr_name)
    if details = YoomeeContentFilter::filter_text(send(attr_name).to_s, :count => true)
      self.content_filter_errors.add(attr_name, "did you mean to say this?", details)
    end
  end
  
  def star_out_filtered_words
    if !content_filter_errors.blank? && acknowledged_failed_content_filter?
      content_filter_errors.each_error do |attr, err|
        self.send("#{attr}=",err.options[:starred])
      end
    end
  end
  
end
