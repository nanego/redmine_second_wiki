require_dependency 'wiki_controller'

class WikiController

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

end
