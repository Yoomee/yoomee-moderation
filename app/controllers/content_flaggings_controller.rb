class ContentFlaggingsController < ModerationBaseController
  
  admin_only :index
  
  def new
    content_flag = get_content_flag
    @content_flagging = content_flag.content_flaggings.build
    render :partial => "content_flaggings/form", :locals => {:content_flagging => @content_flagging}
  end
  
  def create
    @content_flagging = ContentFlagging.new(params[:content_flagging].merge(:user => @logged_in_user, :ip_address => request.remote_ip))
    render :update do |page|
      if @content_flagging.save
        page[:content_flag_form_wrapper].replace(render("content_flaggings/success"))
      else
        page[:content_flag_box].replace(render("content_flaggings/form", :content_flagging => @content_flagging))
      end
      page << "$.fancybox.resize();"
    end
  end
  
  private
  def get_content_flag
    if !params[:attachable_type].blank? && !params[:attachable_id].blank?
      ContentFlag.find_or_create_by_attachable_type_and_attachable_id(params[:attachable_type].camelize, params[:attachable_id])
    elsif !params[:url].blank?
      ContentFlag.find_or_create_by_url(params[:url])
    else
      nil
    end
  end
  
end