class ContentFlaggingNotifier < ActionMailer::Base

  helper :yoomee_moderation
  
  def content_flagging_notification content_flagging
    @content_flagging = content_flagging
    @attachable = @content_flagging.attachable
    mail(:to => APP_CONFIG['admin_email'], 
         :from => moderation_email,
         :subject => "Inappropriate content has been flagged on #{APP_CONFIG['site_name']}")
  end

  private
  def moderation_email
    return APP_CONFIG['site_email'] if !APP_CONFIG['site_email'].blank?
    res = APP_CONFIG['site_url'].match(/^(https?:\/\/)?(www\.)?([^:]+)/)
    "moderation@#{res[3]}"
  end

end
