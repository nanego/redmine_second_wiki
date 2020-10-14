require_dependency 'wiki_helper'

module WikiHelper

  def wiki_page_breadcrumb(page)
    breadcrumb(page.ancestors.reverse.collect { |parent|
      link_to(
          h(parent.pretty_title),
          {:controller => controller.controller_name == 'documentation' ? 'documentation' : 'wiki',
           :action => 'show', :id => parent.title, :project_id => parent.project, :version => nil}
      )
    })
  end

end
