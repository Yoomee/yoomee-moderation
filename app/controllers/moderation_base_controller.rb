class ModerationBaseController < ApplicationController
  
  helper :read_more_truncate

  class_inheritable_hash :permission_levels
  self.permission_levels = {}

  before_filter :gate_keep

  class << self
    
    def admin_only(*actions)
      set_permission_levels(actions, :admin_only)
    end

    def open_action?(action)
      [:open_action, nil].include? permission_level(action.to_sym)
    end

    def permission_level(action)
      permission_levels[action.to_sym]
    end

    protected
    def set_permission_level(action, level)
      level = level.to_sym if !level.is_a?(Proc)
      self.permission_levels[action.to_sym] = level
    end
  
    def set_permission_levels(actions, level)
      actions.flatten.each do |action|
        set_permission_level(action, level)
      end
    end
    
  end
  
  def gate_keep
    if open_action? || (current_user && current_user.admin?)
      true
    else
      raise CanCan::AccessDenied, "You're not allowed to access this page"
    end
  end
  
  def open_action?
    self.class::open_action?(action_name)
  end

  protected
  def replace_moderation_content(partial_name, options={})
    wrapper_class = options.delete(:wrapper_class)
    if !(active_color = options.delete(:active_color))
       active_color = @content_flag_type.nil? ? "#444" : @content_flag_type.color
    end
    
    render :update do |page|
      page << "$('#moderation_right_inner').html('#{escape_javascript(render(partial_name, options))}');"
      page << "$('#moderation_sidebar').replaceWith('#{escape_javascript(render("moderation/sidebar"))}');"
      page << "$('#moderation_wrapper').attr('class', '#{escape_javascript(wrapper_class)}');"
      if active_color
        page << "$('#moderation_right_col').css('border-color', '#{active_color}');"
      end
      page << "ModerationContent.finished();"
      
    end
  end
  
  def set_up_sidebar
    @inbox_count = ContentFlag.unresolved.count
    @content_flag_types ||= ContentFlagType.all
  end
  
end