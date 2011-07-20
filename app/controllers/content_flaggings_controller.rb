class ContentFlaggingsController < ModerationBaseController
    
  def new
    @content_flagging = ContentFlagging.new(:attachable_type => params[:attachable_type], :attachable_id => params[:attachable_id], :url => params[:url])
    render :partial => "content_flaggings/form", :locals => {:content_flagging => @content_flagging}
  end
  
  def create
    @content_flagging = ContentFlagging.new(params[:content_flagging].merge(:user => current_user, :ip_address => request.remote_ip))
    render :update do |page|
      if @content_flagging.save
        page << "$('#content_flag_form_wrapper').replaceWith('#{escape_javascript(render("content_flaggings/success"))}');"
      else
        page << "$('#content_flag_box').replaceWith('#{escape_javascript(render("content_flaggings/form", :content_flagging => @content_flagging))}');"
      end
      page << "$.fancybox.resize();"
    end
  end
  
end