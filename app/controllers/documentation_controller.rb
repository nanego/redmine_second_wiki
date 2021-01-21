require_dependency 'wiki_controller'

class DocumentationController < WikiController

  def rename
    return render_403 unless editable?
    @page.redirect_existing_links = true
    # used to display the *original* title if some AR validation errors occur
    @original_title = @page.pretty_title
    @page.safe_attributes = params[:wiki_page]
    if request.post? && @page.save
      flash[:notice] = l(:notice_successful_update)
      redirect_to project_documentation_page_path(@page.project, @page.title)
    end
  end

  def new
    @page = WikiPage.new(:wiki => @wiki, :title => params[:title])
    unless User.current.allowed_to?(:edit_wiki_pages, @project)
      render_403
      return
    end
    if request.post?
      @page.title = '' unless editable?
      @page.validate
      if @page.errors[:title].blank?

        #############
        # START PATCH
        path = project_documentation_page_path(@project, @page.title, :parent => params[:parent])
        # END PATCH
        #############
        #
        respond_to do |format|
          format.html { redirect_to path }
          format.js   { render :js => "window.location = #{path.to_json}" }
        end
      end
    end
  end

  # Creates a new page or updates an existing one
  def update
    @page = @wiki.find_or_new_page(params[:id])

    return render_403 unless editable?
    was_new_page = @page.new_record?
    @page.safe_attributes = params[:wiki_page]

    @content = @page.content || WikiContent.new(:page => @page)
    content_params = params[:content]
    if content_params.nil? && params[:wiki_page].present?
      content_params = params[:wiki_page].slice(:text, :comments, :version)
    end
    content_params ||= {}

    @content.comments = content_params[:comments]
    @text = content_params[:text]
    if params[:section].present? && Redmine::WikiFormatting.supports_section_edit?
      @section = params[:section].to_i
      @section_hash = params[:section_hash]
      @content.text = Redmine::WikiFormatting.formatter.new(@content.text).update_section(@section, @text, @section_hash)
    else
      @content.version = content_params[:version] if content_params[:version]
      @content.text = @text
    end
    @content.author = User.current

    if @page.save_with_content(@content)
      attachments = Attachment.attach_files(@page, params[:attachments] || (params[:wiki_page] && params[:wiki_page][:uploads]))
      render_attachment_warning_if_needed(@page)
      call_hook(:controller_wiki_edit_after_save, { :params => params, :page => @page})

      respond_to do |format|
        format.html {
          anchor = @section ? "section-#{@section}" : nil
          #############
          # START PATCH
          redirect_to project_documentation_page_path(@project, @page.title, :anchor => anchor)
          # END PATCH
          #############
        }
        format.api {
          if was_new_page
            render :action => 'show', :status => :created, :location => project_wiki_page_path(@project, @page.title)
          else
            render_api_ok
          end
        }
      end
    else
      respond_to do |format|
        format.html { render :action => 'edit' }
        format.api { render_validation_errors(@content) }
      end
    end

  rescue ActiveRecord::StaleObjectError, Redmine::WikiFormatting::StaleSectionError
    # Optimistic locking exception
    respond_to do |format|
      format.html {
        flash.now[:error] = l(:notice_locking_conflict)
        render :action => 'edit'
      }
      format.api { render_api_head :conflict }
    end
  end

  private

  # Finds the requested page or a new page if it doesn't exist
  def find_existing_or_new_page
    @documentation = @project.documentation
    @page = @documentation.find_or_new_page(params[:id])
    if @documentation.page_found_with_redirect?
      redirect_to_page @page
    end
  end

end
