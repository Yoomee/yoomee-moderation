module ReadMoreTruncateHelper
  
  def read_more_truncate(text, options = {})
    return if text.blank?
    options.reverse_merge!(:length => 400, :simple_format => true, :more_link => "Read more", :less_link => "Read less", :truncate_string => '...', :quotes => false)
    text = strip_tags(text)
    if text.length <= options[:length]
      text = "\"#{text}\"" if options[:quotes]
      if options[:simple_format]
        return auto_link(simple_format(text), :target => '_blank')
      else
        return auto_link(text, :target => '_blank')
      end
    end
    javascript = "var par = $(this).parentsUntil('.read_more_wrapper').last(); par.hide(); par.siblings().show();"
    read_more_link = link_to_function(options[:more_link], javascript, :class => 'read_more_link')
    read_less_link = link_to_function(options[:less_link], javascript, :class => 'read_less_link')

    head = truncate(text, :length => options[:length], :truncate_string => options[:truncate_string])
    head = auto_link(head, :all, :target => "_blank")
    head = head + read_more_link
    
    text = auto_link(text, :all, :target => "_blank")
    full = text + read_less_link
    
    if options[:quotes]
      head = "\"#{head}\""
      full = "\"#{full}\""
    end
    if options[:simple_format]
      head = simple_format(head)
      full = simple_format(full)
    end
    
    ret = "<span class='read_more_wrapper'>
            <span class='read_more_trunc'>
              #{head}
            </span>
            <span class='read_more_full' style='display:none'>
              #{full}
            </span>
          </span>" 
  end
  
end