Factory.define(:content_flagging) do |c|
  c.association :content_flag
  c.association :content_flag_type, :factory => :content_flag_type
  c.association :user, :factory => :user
  c.message "This page has inappropriate content"
end
