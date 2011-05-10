Factory.define(:content_flag_field) do |c|
  c.association :content_flag, :factory => :content_flag
  c.name "forename"
  c.value "Fudge McGee"
end