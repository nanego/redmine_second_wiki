Deface::Override.new :virtual_path => "wiki/history",
                     :name         => "replace-url-for-new-wiki-link-in-history",
                     :replace      => "erb[loud]:contains('l(:label_history)')",
                     :text         => <<LINK
<% if controller.controller_name == 'documentation' %>
  <%= title [@page.pretty_title, project_documentation_page_path(@page.project, @page.title, :version => nil)], l(:label_history) %>
<% else %>
  <%= title [@page.pretty_title, project_wiki_page_path(@page.project, @page.title, :version => nil)], l(:label_history) %>
<% end %>
LINK
