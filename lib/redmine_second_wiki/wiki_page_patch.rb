require_dependency 'wiki_page'

class WikiPage < ActiveRecord::Base

  def visible?(user = User.current)
    !user.nil? && (
      (wiki_page? && user.allowed_to?(:view_wiki_pages, project)) ||
        (documentation_page? && user.allowed_to?(:view_documentation_pages, project))
    )
  end

  def root_page
    if is_a_start_page?
      self
    else
      parent_page = self.parent
      if parent_page.present?
        parent_page.root_page
      else
        nil
      end
    end
  end

  def documentation_page?
    if root_page.present?
      root_page.pretty_title == wiki.documentation_start_page
    else
      true
    end
  end

  def wiki_page?
    if root_page.present?
      root_page.pretty_title == wiki.start_page
    else
      true
    end
  end

  def is_a_start_page?
    pretty_title == wiki.documentation_start_page || pretty_title == wiki.start_page
  end

end
