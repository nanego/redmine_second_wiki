require_dependency 'wiki_page'

class WikiPage < ActiveRecord::Base

  safe_attributes 'parent_id', 'parent_title', 'title', 'redirect_existing_links', 'wiki_id',
                  :if => lambda {|page, user| page.new_record? || user.allowed_to?(:rename_wiki_pages, page.project) || user.allowed_to?(:rename_documentation_pages, page.project)}

  safe_attributes 'is_start_page',
                  :if => lambda {|page, user| user.allowed_to?(:manage_wiki, page.project) || user.allowed_to?(:manage_documentation, page.project)}

  def visible?(user = User.current)
    !user.nil? && (
      (wiki_page? && user.allowed_to?(:view_wiki_pages, project)) ||
        (documentation_page? && user.allowed_to?(:view_documentation_pages, project))
    )
  end

  def editable_by?(usr)
    !protected? || (wiki_page? && usr.allowed_to?(:protect_wiki_pages, project)) || (documentation_page? && usr.allowed_to?(:protect_documentation_pages, project))
  end

  def safe_attributes=(attrs, user=User.current)
    if attrs.respond_to?(:to_unsafe_hash)
      attrs = attrs.to_unsafe_hash
    end

    return unless attrs.is_a?(Hash)
    attrs = attrs.deep_dup

    # Project and Tracker must be set before since new_statuses_allowed_to depends on it.
    if (w_id = attrs.delete('wiki_id')) && safe_attribute?('wiki_id')
      if (w = Wiki.find_by_id(w_id)) && w.project && (user.allowed_to?(:rename_wiki_pages, w.project) || user.allowed_to?(:rename_documentation_pages, w.project))
        self.wiki = w
      end
    end

    super attrs, user
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
      self&.persisted? ? false : true
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
