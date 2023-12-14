module RedmineSecondWiki
  module WikiHelperPatch

    def wiki_page_breadcrumb(page)
      breadcrumb(page.ancestors.reverse.collect { |parent|
        link_to(
          h(parent.pretty_title),
          { :controller => controller.controller_name,
            :action => 'show',
            :id => parent.title,
            :project_id => parent.project,
            :version => nil }
        )
      })
    end

    # Returns the path for the Cancel link when editing a Documentation page
    def documentation_page_edit_cancel_path(page)
      if page.new_record?
        if parent = page.parent
          project_documentation_page_path(parent.project, parent.title)
        else
          project_documentation_index_path(page.project)
        end
      else
        project_documentation_page_path(page.project, page.title)
      end
    end

  end
end

WikiHelper.prepend RedmineSecondWiki::WikiHelperPatch
ActionView::Base.send(:include, WikiHelper)
