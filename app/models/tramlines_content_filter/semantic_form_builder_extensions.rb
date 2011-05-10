module TramlinesContentFilter::SemanticFormBuilderExtensions
  
  def self.included(klass)
    klass.alias_method_chain :inline_errors_for, :content_filter
    klass.alias_method_chain :input, :content_filter
  end  
  
  def inline_errors_for_with_content_filter(method, options = nil)
    if !@object.errors.empty? || !@object.respond_to?(:content_filter_errors)
      inline_errors_for_without_content_filter(method, options)
    else
      if render_inline_errors?
        errors = [@object.content_filter_errors[method.to_sym]]
        errors << [@object.content_filter_errors[association_primary_key(method)]] if association_macro_for_method(method) == :belongs_to
        errors = errors.flatten.compact.uniq
        send(:"error_sentence", [*errors]) if errors.any?
      else
        nil
      end
    end
  end
  
  def input_with_content_filter(method, options = {})
    if @object && @object.errors.blank? && @object.respond_to?(:content_filter_errors) && !@object.content_filter_errors.blank?
      ret = ""
      if !@inserted_content_filter_javascript && !@object.content_filter_errors.blank?
        @inserted_content_filter_javascript = true
        ret = content_filter_box(@object) + self.input(:acknowledged_failed_content_filter, :as => :hidden)
      end
      if !@object.content_filter_errors[method.to_sym].blank?
        ret += input_without_content_filter(method, options).gsub(/<li class=\"/, "<li class=\"error ")
      else
        ret += input_without_content_filter(method, options)
      end
    else
      input_without_content_filter(method, options)
    end
  end
  
  
  private
  def content_filter_box(object)
    "<div id='content_filter_js' style='display:none'>
      <script type='text/javascript'>
        $(document).ready(function(){
          $('#fancybox-old').remove();
          if ($('#fancybox-inner').html().length > 0) {
            $('#fancybox-wrap').after('<div id=\"fancybox-old\">' + $('#fancybox-inner').html() + '</div>');
          }
          $.fancybox(
 '#{escape_javascript(ActionView::Base.new("#{RAILS_ROOT}/vendor/plugins/tramlines_content_flags/app/views").render(:partial => "content_filter/content_filter_box", :locals => {:form => self, :form_id => formtastic_form_id }))}',
              {'autoDimensions':false,
                'width':350,
                'height':'auto',
                'transitionIn':'none',
                'transitionOut':'none'
                }
          );
        });
        </script>
    </div>"
  end
  
  def formtastic_form_id
    return options[:html][:id] unless options[:html].blank? || options[:html][:id].blank?
    @object.new_record? ? dom_id(@object) : dom_id(@object, :edit)
  end 
  
end


