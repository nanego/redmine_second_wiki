Deface::Override.new :virtual_path => "wiki/annotate",
                     :name         => "replace-url-for-new-wiki-link-in-annotate",
                     :replace      => "erb[loud]:contains('title [@page.pretty_title')",
                     :text         => <<LINK
<% if controller.controller_name == 'documentation' %>
  <%= title [@page.pretty_title, project_documentation_page_path(@page.project, @page.title, :version => nil)],
      [l(:label_history), history_project_documentation_page_path(@page.project, @page.title)],
      l(:label_version) + @annotate.content.version.to_s %>
<% else %>
  <%= title [@page.pretty_title, project_wiki_page_path(@page.project, @page.title, :version => nil)],
      [l(:label_history), history_project_wiki_page_path(@page.project, @page.title)],
      l(:label_version) + @annotate.content.version.to_s %>
<% end %>
LINK
