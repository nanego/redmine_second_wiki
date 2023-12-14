module RedmineSecondWiki
  class Hooks < Redmine::Hook::ViewListener
    # adds our css on each page
    def view_layouts_base_html_head(context)
      stylesheet_link_tag("second_wiki", :plugin => "redmine_second_wiki")
    end

    class ModelHook < Redmine::Hook::Listener

      def after_plugins_loaded(_context = {})
        require_relative 'wiki_helper_patch'
        require_relative 'application_helper_patch'
        require_relative 'project_patch'
        require_relative 'wiki_patch'
        require_relative 'wiki_page_patch'
        require_relative 'wiki_controller_patch'
        require_relative 'attachments_controller_patch'
      end
    end

  end
end
