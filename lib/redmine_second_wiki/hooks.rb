module RedmineSecondWiki
  class Hooks < Redmine::Hook::ViewListener
    #adds our css on each page
    def view_layouts_base_html_head(context)
      stylesheet_link_tag("second_wiki", :plugin => "redmine_second_wiki")  
    end   

  end
end
