Factory.define(:content_flag) do |f|
  f.association :attachable, :factory => :asset
end