Deface::Override.new :virtual_path => "wiki/index",
                     :name         => "replace-condition-in-index-page",
                     :replace      => "erb[silent]:contains('if User.current.allowed_to?(:edit_wiki_pages, @project)')",
                     :text         => <<EOS
<% if User.current.allowed_to?(:edit_wiki_pages, @project) || User.current.allowed_to?(:edit_documentation_pages, @project) %>
EOS

Deface::Override.new :virtual_path => "wiki/index",
                     :name         => "replace-url-for-new-wiki-link-in-index",
                     :replace      => "erb[loud]:contains('link_to l(:label_wiki_page_new)')",
                     :text         => <<LINK
<% if controller.controller_name == 'documentation' %>
  <%= link_to l(:label_wiki_page_new), new_project_documentation_page_path(@project), :remote => true, :class => 'icon icon-add' %>
<% else %>
  <%= link_to l(:label_wiki_page_new), new_project_wiki_page_path(@project), :remote => true, :class => 'icon icon-add' %>
<% end %>
LINK

Deface::Override.new :virtual_path => "wiki/index",
                     :name         => "replace-manage-condition-in-index-page",
                     :replace      => "erb[silent]:contains('if User.current.allowed_to?(:manage_wiki, @project)')",
                     :text         => <<EOS
<% if User.current.allowed_to?(:manage_wiki, @project) || User.current.allowed_to?(:manage_documentation, @project) %>
EOS

Deface::Override.new :virtual_path => "wiki/index",
                     :name         => "replace-url-for-delete-wiki-link-in-index",
                     :replace      => "erb[loud]:contains('link_to l(:button_delete)')",
                     :text         => <<LINK
<% if controller.controller_name == 'documentation' %>
  <%# Documentation deletion is disabled %>
<% else %>
  <%= link_to l(:button_delete), {:controller => 'wikis', :action => 'destroy', :id => @project}, :class => 'icon icon-del' %>
<% end %>
LINK

Deface::Override.new :virtual_path => "wiki/index",
                     :name         => "replace-export-condition-in-index-page",
                     :replace      => "erb[silent]:contains('if User.current.allowed_to?(:export_wiki_pages, @project)')",
                     :text         => <<EOS
<% if User.current.allowed_to?(:export_wiki_pages, @project) || User.current.allowed_to?(:export_documentation_pages, @project) %>
EOS

Deface::Override.new :virtual_path => "wiki/index",
                     :name         => "replace-rendered-page-hierarchy-in-index-page",
                     :replace      => "erb[loud]:contains('render_page_hierarchy')",
                     :text         => <<EOS
<% if controller.controller_name == 'documentation' %>
  <%= render_documentation_page_hierarchy(@pages_by_parent_id, nil, :timestamp => true) %>
<% else %>
  <%= render_page_hierarchy(@pages_by_parent_id, nil, :timestamp => true) %>
<% end %>
EOS


