class Documentation < Wiki

  def visible?(user=User.current)
    !user.nil? && user.allowed_to?(:view_documentation_pages, project)
  end

  # find the page with the given title
  # if page doesn't exist, return a new page
  def find_or_new_page(title)
    title = documentation_start_page if title.blank?
    find_page(title) || WikiPage.new(:wiki => self, :title => Wiki.titleize(title))
  end

end
