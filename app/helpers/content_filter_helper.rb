module ContentFilterHelper
  
  def content_filter_javascript
    if !(objs = objects_with_content_filter_errors).blank?
      text = ""
      objs.each do |obj|
        obj.content_filter_errors.each_full do |err|
          text += content_tag(:p, err)
        end
      end
      javascript_tag do
        <<-JS
        $(document).ready(function() {
          $.fancybox(
            '<h2>Did you mean to say that?</h2>#{text}',
          	{
            	'autoDimensions'	: false,
          	  'width'         		: 350,
          		'height'        		: 'auto',
          		'transitionIn'		: 'none',
          		'transitionOut'		: 'none'
          	}
          );          
        })
        JS
      end
    end
  end
  
  def objects_with_content_filter_errors
    out = []
    ObjectSpace.each_object(ActiveRecord::Base) {|obj| out << obj if obj.errors.empty? && !obj.content_filter_errors.empty? && !out.include?(obj)}
    out
  end
  
end