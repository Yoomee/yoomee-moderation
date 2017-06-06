class ContentFlagsController < ModerationBaseController

  admin_only :index, :inbox, :resolve, :unresolve, :resolved, :show

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
    set_up_sidebar
    render :template => 'moderation/index'
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
    if params[:q].present?
      term = params[:q].strip
      post_flags = ContentFlag.search_posts(term)
      comment_flags = ContentFlag.search_comments(term)
      message_flags = ContentFlag.search_messages(term)
      user_flags = ContentFlag.search_users(term)
      @content_flags = post_flags + comment_flags + message_flags + user_flags
    else
      @content_flags = ContentFlag.resolved.descend_by_resolved_at.paginate(:per_page => 20, :page => params[:page])
    end

    set_up_sidebar
    if request.xhr?
      replace_moderation_content('content_flag_list', :content_flags => @content_flags, :content_flag_types => @content_flag_types, :active_li => "resolved")
    else
      render :template => 'moderation/index'
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
