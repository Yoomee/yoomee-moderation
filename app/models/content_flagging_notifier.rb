class ContentFlaggingNotifier < ActionMailer::Base

  helper :content_flags
  
  def content_flagging_notification content_flagging
    @content_flagging = content_flagging
    @attachable = @content_flagging.attachable
    mail(:to => APP_CONFIG['admin_email'], 
         :from => moderation_email,
         :subject => "Inappropriate content has been flagged on #{APP_CONFIG['site_name']}")
  end
  
  # def content_flagging_notification content_flagging
  #   recipients APP_CONFIG['admin_email']
  #   from moderation_email
  #   subject "Inappropriate content has been flagged on #{APP_CONFIG['site_name']}"
  #   content_type "multipart/alternative"
  #   locals = {:content_flagging => content_flagging, :attachable => content_flagging.attachable}
  #   part :content_type => "text/plain", :body => render_message("content_flagging_notification.text.plain", locals)
  #   part :content_type => "text/html", :body => render_message("content_flagging_notification.text.html", locals)
  # end

  private
  def moderation_email
    return APP_CONFIG['site_email'] if !APP_CONFIG['site_email'].blank?
    res = APP_CONFIG['site_url'].match(/^(https?:\/\/)?(www\.)?([^:]+)/)
    "moderation@#{res[3]}"
  end

end
