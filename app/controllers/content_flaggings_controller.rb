class ContentFlaggingsController < ModerationBaseController

  def new
    @content_flagging = ContentFlagging.new(:attachable_type => params[:attachable_type], :attachable_id => params[:attachable_id], :url => params[:url])
    render :partial => "content_flaggings/form", :locals => {:content_flagging => @content_flagging}
  end

  def create
    @content_flagging = ContentFlagging.new(content_flagging_params.merge(:user => current_user, :ip_address => request.remote_ip))
    @success = @content_flagging.save
    respond_to do |format|
      format.js
    end

  end

  private

  def content_flagging_params
    params.require(:content_flagging).permit(:attachable_type, :attachable_id, :url, :message, :email, :content_flag_type_id)
  end

end
