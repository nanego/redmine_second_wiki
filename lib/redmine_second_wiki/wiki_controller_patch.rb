require_dependency 'wiki_controller'

class WikiController

  append_before_action :redirect_if_documentation, :only => [:show, :protect, :history, :diff, :annotate, :export, :add_attachment]
  append_before_action :set_attachable_options

  def load_pages_for_index
    @pages = @wiki.pages.with_updated_on.
      includes(:wiki => :project).
      includes(:parent).
      to_a - @wiki.documentation_pages
  end

  # Returns true if the current user is allowed to edit the page, otherwise false
  def editable?(page = @page)
    page.editable_by?(User.current) && page.wiki_page?
  end

  def redirect_if_documentation
    if @page&.persisted? && @page.documentation_page? && controller_name != 'documentation'
      redirect_to controller: 'documentation', action: action_name, project_id: @page.project, id: @page.title
    end
  end

  def set_attachable_options
    if @page
      if @page.documentation_page?
        @page.class.attachable_options[:view_permission] = "view_documentation_pages".to_sym
        @page.class.attachable_options[:edit_permission] = "edit_documentation_pages".to_sym
        @page.class.attachable_options[:delete_permission] = "edit_documentation_pages".to_sym
      else
        @page.class.attachable_options[:view_permission] = "view_wiki_pages".to_sym
        @page.class.attachable_options[:edit_permission] = "edit_wiki_pages".to_sym
        @page.class.attachable_options[:delete_permission] = "edit_wiki_pages".to_sym
      end
    end
  end

end
