module YoomeeModerationHelper
  
  def content_flag_link(*args)
    #include_yoomee_fancybox_js
    options = args.extract_options!
    options.reverse_merge!(:text => "Report")
    attachable = args.first
    options[:class] = "content_flag_link yoomee_fancy #{options[:class]}"
    if attachable.nil?
      link_to options.delete(:text), new_moderation_content_flagging_path(:url => options.delete(:url) || request.request_uri), options
    else
      link_to options.delete(:text), "/#{attachable.class.to_s.underscore}/#{attachable.id}/content_flaggings/new", options    
    end
  end
  alias_method :yoomee_flag_link, :content_flag_link
  
  def content_flag_url(content_flag)
    content_flag.attachable.nil? ? content_flag.url : url_for(content_flag.attachable)
  end
  
  def content_flag_type_box(content_flag)
    stripes = ""
    unless (colors = content_flag.content_flag_types.ascend_by_name.uniq.collect(&:color)).blank?
      stripe_width = (20/colors.size.to_f).round
      colors.each do |color|
        width = (color == colors.last ? 20 - stripe_width*(colors.size - 1) : stripe_width)
        stripes << content_tag(:div, "", :class => "stripe", :style => "background-color:#{color};width:#{width}px")
      end
    end
    content_tag(:div, stripes.html_safe, :class => "content_flag_type_box")
  end
  
  def content_flag_type_label(content_flag_type)
    content_tag(:span, content_flag_type, :class => "content_flag_type_label", :style => "background-color:#{content_flag_type.try(:color) || "#2795E4"}")
  end
  
  def include_yoomee_fancybox_js
    return true if @included_ymfb_js
    content_for :head do
      content = javascript_include_tag('/yoomee_moderation/jquery.fancybox-1.3.4.pack.js',
                             '/yoomee_moderation/jquery.easing-1.3.pack.js',
                             '/yoomee_moderation/load_fancybox.js',
                             '/yoomee_moderation/jquery.mousewheel-3.0.2.pack.js', 
                              :cache => "yoomee_fancy_box")
    content << "\n#{stylesheet_link_tag('/yoomee_moderation/jquery.fancybox.css', '/yoomee_moderation/content_flag_box.css')}".html_safe
    end
    @included_ymfb_js = true
  end
  
  def link_to_moderation_content(*args, &block)
    defaults = {:method => :get, :remote => true}
    defaults[:class] = "moderation_content_link #{defaults[:class]}".strip
    if block_given?
      args[1] ||= {}
      args[1].reverse_merge!(defaults)
    else
      args[2] ||= {}
      args[2].reverse_merge!(defaults)
    end
    link_to(*args, &block)
  end
  
  def link_to_url(url, *args, &block)
    options = args.extract_options!.symbolize_keys.reverse_merge!(:http => true, :target => "_blank")
    link_url = url.match(/^.+\:\/\//) ? url : "http://" + url
    url = url.sub(/^https?:\/\//, '') if !options.delete(:http)
    link_to(url, link_url, options, &block)
  end
  
  def moderation_back_link
    if params[:menu_item]=="content_flag_type" && @content_flag_type
      url = moderation_content_flag_type_path(@content_flag_type)
    else
      url = params[:menu_item]=="resolved" ? resolved_moderation_content_flags_path : inbox_moderation_content_flags_path
    end
    link_to_moderation_content("&larr; Back".html_safe, url)
  end
  
  def moderation_image_tag(source, options = {})
    image_tag("yoomee_moderation/img/#{source}", options)
  end
  
  def moderation_nav_links(content_flag)
    options = {:menu_item => params[:menu_item], :content_flag_type_id => @content_flag_type.try(:id)}
    out = ""
    if prev_content_flag = content_flag.prev(options)
      out << link_to_moderation_content("< Previous", moderation_content_flag_path(prev_content_flag, options))
    else
      out << content_tag(:span, "< Previous")
    end
    if next_content_flag = content_flag.next(options)
      out << link_to_moderation_content("Next >", moderation_content_flag_path(next_content_flag, options))
    else
      out << content_tag(:span, "Next >")
    end
    out.html_safe
  end
  
  
end

