require_dependency 'wiki'

class Wiki < ActiveRecord::Base

  def documentation_pages
    find_page(documentation_start_page).self_and_descendants
  end

end
