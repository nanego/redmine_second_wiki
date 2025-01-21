require 'wiki'

module RedmineSecondWiki
  module WikiPatch

  end
end

class Wiki

  prepend RedmineSecondWiki::WikiPatch

  def documentation_pages
    root_page = root_documentation_page
    if root_page.present?
      root_page.self_and_descendants
    else
      []
    end
  end

  def root_documentation_page
    find_page(documentation_start_page)
  end

  def root_wiki_page
    find_page(start_page)
  end
end
