module YoomeeContentFlags::NotifierExtensions
  
  def self.included(klass)
    klass.helper :content_flags
  end
  
  def content_flag_notification content_flag
    site_name = APP_CONFIG['site_name']
    site_url = APP_CONFIG['site_url']
    recipients APP_CONFIG['content_flag_email'] || APP_CONFIG['site_email']
    from APP_CONFIG['site_email']
    subject "Inappropriate content has been flagged on #{APP_CONFIG['site_name']}"
    content_type "multipart/alternative"
    locals = {:content_flag => content_flag, :attachable => content_flag.attachable}
    part :content_type => "text/plain", :body => render_message("content_flag_notification.text.plain", locals)
    part :content_type => "text/html", :body => render_message("content_flag_notification.text.html", locals)
  end

end
