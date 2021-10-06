require_dependency 'wiki_controller'

class DocumentationController < WikiController

  # display a page (in editing mode if it doesn't exist)
  def show
    if params[:version] && !User.current.allowed_to?(:view_documentation_edits, @project)
      deny_access
      return
    end
    return render_403 if @page.wiki_page?
    @content = @page.content_for_version(params[:version])
    if @content.nil?
      if User.current.allowed_to?(:edit_documentation_pages, @project) && editable? && !api_request?
        edit
        render :action => 'edit'
      else
        render_404
      end
      return
    end

    call_hook :controller_documentation_show_before_render, content: @content, format: params[:format]

    if User.current.allowed_to?(:export_documentation_pages, @project)
      if params[:format] == 'pdf'
        send_file_headers! :type => 'application/pdf', :filename => filename_for_content_disposition("#{@page.title}.pdf")
        return
      elsif params[:format] == 'html'
        export = render_to_string :action => 'export', :layout => false
        send_data(export, :type => 'text/html', :filename => filename_for_content_disposition("#{@page.title}.html"))
        return
      elsif params[:format] == 'txt'
        send_data(@content.text, :type => 'text/plain', :filename => filename_for_content_disposition("#{@page.title}.txt"))
        return
      end
    end
    @editable = editable?
    @sections_editable = @editable && User.current.allowed_to?(:edit_documentation_pages, @page.project) &&
      @content.current_version? &&
      Redmine::WikiFormatting.supports_section_edit?

    respond_to do |format|
      format.html
      format.api
    end
  end

  def rename
    return render_403 unless editable?
    @page.redirect_existing_links = true
    # used to display the *original* title if some AR validation errors occur
    @original_title = @page.pretty_title
    @page.safe_attributes = params[:wiki_page]
    if request.post? && @page.save
      flash[:notice] = l(:notice_successful_update)
      #############
      # START PATCH
      redirect_to project_documentation_page_path(@page.project, @page.title)
      # END PATCH
      #############
    end
  end

  def new
    @page = WikiPage.new(:wiki => @wiki, :title => params[:title])
    unless User.current.allowed_to?(:edit_documentation_pages, @project)
      render_403
      return
    end
    if request.post?
      @page.title = '' unless editable?
      @page.validate
      if @page.errors[:title].blank?

        #############
        # START PATCH
        parent = params[:parent] || @wiki.documentation_start_page
        path = project_documentation_page_path(@project, @page.title, :parent => parent)
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

    @page.parent = @wiki.root_documentation_page if @page.parent.blank?
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
            render :action => 'show', :status => :created, :location => project_documentation_page_path(@project, @page.title)
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

  def protect
    return render_403 if @page.wiki_page?
    @page.update_attribute :protected, params[:protected]
    redirect_to project_documentation_page_path(@project, @page.title)
  end

  def destroy
    return render_403 unless editable?

    @descendants_count = @page.descendants.size
    if @descendants_count > 0
      case params[:todo]
      when 'nullify'
        # Nothing to do
      when 'destroy'
        # Removes all its descendants
        @page.descendants.each(&:destroy)
      when 'reassign'
        # Reassign children to another parent page
        reassign_to = @wiki.pages.find_by_id(params[:reassign_to_id].to_i)
        return unless reassign_to
        @page.children.each do |child|
          child.update_attribute(:parent, reassign_to)
        end
      else
        @reassignable_to = @wiki.pages - @page.self_and_descendants
        # display the destroy form if it's a user request
        return unless api_request?
      end
    end
    @page.destroy
    respond_to do |format|
      #############
      # START PATCH
      format.html { redirect_to project_documentation_index_path(@project) }
      # END PATCH
      #############
      format.api { render_api_ok }
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

  def load_pages_for_index
    @pages = @wiki.documentation_pages
  end

  # Returns true if the current user is allowed to edit the page, otherwise false
  def editable?(page = @page)
    page.editable_by?(User.current) && page.documentation_page?
  end

end
