require_dependency 'wiki_controller'

class WikiController

  append_before_action :render_403_if_documentation, :only => [:show, :protect, :history, :diff, :annotate, :export, :add_attachment]

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

  def render_403_if_documentation
    if @page.persisted? && controller_name != 'documentation' && @page.documentation_page?
      return render_403
    end
  end

end
