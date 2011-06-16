# require 'googlecharts'
# require 'haml'
class ContentFlagsController < ModerationBaseController
  
  admin_only :index, :remove, :resolve, :restore, :resolved
  
  def new
    @content_flag = ContentFlag.new(:url => params[:url], :attachable => get_attachable)
    render :partial => "content_flags/form", :locals => {:content_flag => @content_flag}
  end
  
  def create
    @content_flag = ContentFlag.new(params[:content_flag].merge(:user => current_user))
    render :update do |page|
      if @content_flag.save
        page[:content_flag_form_wrapper].replace(render("content_flags/success"))
        page << "$.fancybox.resize();"
      else
        page[:content_flag_box].replace(render("content_flags/form", :content_flag => @content_flag))
      end
    end
  end
  
  def index
    @dashboard = true
    @flaggings = ContentFlagging.last_month         
    max = ContentFlagging.last_month_max
    @flag_timeline = Gchart.bar(:data => @flaggings[1], :size => "610x150", :max_value => max, :bar_width_and_spacing => [17,4], :axis_labels => [@flaggings[0].join('|')], :axis_with_labels => 'x,y', :bar_colors => ContentFlagType.all.collect(&:hex_color), :axis_range => [[],[0,max]], :bg_color => "444444", :custom => "&chxs=0,cccccc,9.5,0,l,cccccc|1,cccccc,9.5,0,l,cccccc")
    
    @average_response = ContentFlag.average_response
    @flag_type_counts = ContentFlagging.flag_type_counts
    
    @flag_type_pie = Gchart.pie(:data => @flag_type_counts, :size => "140x140", :bar_colors => ContentFlagType.all.collect(&:hex_color), :bg_color => "444444")
    
    set_up_sidebar
    if request.xhr?
      replace_moderation_content('moderation/dashboard', :flag_timeline => @flag_timeline, :average_response => @average_response, :flag_type_pie => @flag_type_pie)
    else
      render :template => 'moderation/index'
    end
  end
  
  def inbox
    @content_flags = ContentFlag.unresolved.latest
    set_up_sidebar
    if request.xhr?
      replace_moderation_content('content_flag_list', :content_flags => @content_flags, :content_flag_types => @content_flag_types, :active_li => "inbox")
    else
      render :template => 'moderation/index'
    end
  end
  
  # Marks attachable as removed
  def remove
    @content_flag = ContentFlag.find(params[:id])
    if @content_flag.removable?
      @content_flag.attachable.update_attributes(:removed_by => current_user, :removed_at => Time.now)
    end
    if params[:in_moderation]
      replace_moderation_content('content_flag', :content_flag => @content_flag)
    else
      nil
    end
  end
  
  def resolve
    @content_flag = ContentFlag.find(params[:id])
    @content_flag.resolve!(current_user)
    @content_flag_type = ContentFlagType.find_by_id(params[:content_flag_type_id])
    if next_content_flag = @content_flag.next(:menu_item => params[:menu_item], :content_flag_type_id => @content_flag_type.try(:id))
      replace_moderation_content('content_flag', :content_flag => next_content_flag)
    elsif @content_flag_type
      replace_moderation_content("content_flags/content_flag_list", :content_flags => @content_flag_type.content_flags.unresolved.latest, :active_li => "content_flag_type_#{@content_flag_type.id}", :active_color => @content_flag_type.color)
    else
      set_up_sidebar
      replace_moderation_content('content_flag_list', :content_flags => ContentFlag.unresolved.latest, :content_flag_types => @content_flag_types, :active_li => "inbox")
    end
  end
  
  def resolved
    @content_flags = ContentFlag.resolved.descend_by_resolved_at
    set_up_sidebar
    if request.xhr?
      replace_moderation_content('content_flag_list', :content_flags => @content_flags, :content_flag_types => @content_flag_types, :active_li => "resolved")
    else
      render :template => 'moderation/index'
    end
  end
  
  # Marks attachable as removed
  def restore
    @content_flag = ContentFlag.find(params[:id])
    if @content_flag.removable?
      @content_flag.attachable.update_attributes(:removed_by => nil, :removed_at => nil)
    end
    if params[:in_moderation]
      replace_moderation_content('content_flag', :content_flag => @content_flag)
    else
      nil
    end
  end
  
  def unresolve
    @content_flag = ContentFlag.find(params[:id])
    @content_flag.unresolve!
    replace_moderation_content('content_flag', :content_flag => @content_flag)
  end
  
  def show
    @content_flag = ContentFlag.find(params[:id])
    @content_flag_type = ContentFlagType.find_by_id(params[:content_flag_type_id])
    if request.xhr?
      replace_moderation_content('content_flag', :content_flag => @content_flag)
    else
      set_up_sidebar
      render :template => 'moderation/index'
    end
  end
  
  private
  def get_attachable
    return nil if params[:attachable_type].blank? || params[:attachable_id].blank?
    params[:attachable_type].camelize.constantize.find(params[:attachable_id])
  end
  
end