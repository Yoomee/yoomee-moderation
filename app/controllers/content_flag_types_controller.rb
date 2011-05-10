class ContentFlagTypesController < ModerationBaseController
  
  admin_only %w{create destroy index show update}
  before_filter :get_content_flag_type, :only => %w{destroy show update}
    
  def index
    @content_flag_types = ContentFlagType.all(:order => :name)
    if request.xhr?
      replace_moderation_content('content_flag_types/content_flag_types_list', :content_flag_types => @content_flag_types)
    else
      render :template => 'content_flag_types/index'
    end
  end
  
  def create
    @content_flag_type = ContentFlagType.new(params[:content_flag_type])
    render :update do |page|
      show_form = false
      if @content_flag_type.save
        page << "$('#new_content_flag_type').after('#{escape_javascript(render("content_flag_types/content_flag_type", :content_flag_type => @content_flag_type, :show_form => false))}');"
        # page << "$('##{@content_flag_type.id}_content_flag_type').effect('highlight', {color:'#E3EBF3'}, 3000);"
        @content_flag_type = ContentFlagType.new
      else
        show_form = true
      end
      page << "$('#new_content_flag_type').replaceWith('#{escape_javascript(render("content_flag_types/new_content_flag_type", :content_flag_type => @content_flag_type, :show_form => show_form))}');"
    end
  end
  
  def destroy
    render :update do |page|
      if @content_flag_type.destroy
        page << "$('##{@content_flag_type.id}_content_flag_type').remove();"
      else
        render :nothing => true
      end
    end
  end
  
  def show
    if request.xhr?
      replace_moderation_content("content_flags/content_flag_list", :content_flags => @content_flag_type.content_flags.unresolved.latest, :active_li => "content_flag_type_#{@content_flag_type.id}", :active_color => @content_flag_type.color)
    else
      set_up_sidebar 
      render :template => 'moderation/index'
    end
  end
  
  def update
    render :update do |page|
      if @content_flag_type.update_attributes(params[:content_flag_type])
        page << "$('##{@content_flag_type.id}_content_flag_type').replaceWith('#{escape_javascript(render("content_flag_types/content_flag_type", :content_flag_type => @content_flag_type, :show_form => false))}');"
      else
        page << "$('##{@content_flag_type.id}_content_flag_type_form').replaceWith('#{escape_javascript(render("content_flag_types/form", :content_flag_type => @content_flag_type, :method => :put, :show_form => true))}');"
        page << "CategoryForm.show_form('#{@content_flag_type.id}')"
      end
    end
  end
  
  private
  def get_content_flag_type
    @content_flag_type = ContentFlagType.find(params[:id])
  end
end
