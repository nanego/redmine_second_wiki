Deface::Override.new :virtual_path => "wiki/date_index",
                     :name         => "replace-condition-in-date-index-page",
                     :replace      => "erb[silent]:contains('if User.current.allowed_to?(:edit_wiki_pages, @project)')",
                     :text         => <<EOS
<% if User.current.allowed_to?(:edit_wiki_pages, @project) || User.current.allowed_to?(:edit_documentation_pages, @project) %>
EOS

Deface::Override.new :virtual_path => "wiki/date_index",
                     :name         => "replace-url-for-new-wiki-link-in-date-index",
                     :replace      => "erb[loud]:contains('l(:label_wiki_page_new)')",
                     :text         => <<LINK
<% if controller.controller_name == 'documentation' %>
  <%= link_to sprite_icon('add', l(:label_wiki_page_new)), new_project_documentation_page_path(@project), :remote => true, :class => 'icon icon-add' %>
<% else %>
  <%= link_to sprite_icon('add', l(:label_wiki_page_new)), new_project_wiki_page_path(@project), :remote => true, :class => 'icon icon-add' %>
<% end %>
LINK

Deface::Override.new :virtual_path => "wiki/date_index",
                     :name         => "replace-manage-condition-in-date-index-page",
                     :replace      => "erb[silent]:contains('if User.current.allowed_to?(:manage_wiki, @project)')",
                     :text         => <<EOS
<% if User.current.allowed_to?(:manage_wiki, @project) || User.current.allowed_to?(:manage_documentation, @project) %>
EOS

Deface::Override.new :virtual_path => "wiki/date_index",
                     :name         => "replace-url-for-delete-wiki-link-in-date-index",
                     :replace      => "erb[loud]:contains('l(:button_delete)')",
                     :text         => <<LINK
<% if controller.controller_name == 'documentation' %>
  <%# Documentation deletion is disabled %>
<% else %>
  <%= link_to sprite_icon('del', l(:button_delete)), { :controller => 'wikis', :action => 'destroy', :id => @project}, :class => 'icon icon-del' %>
<% end %>
LINK

Deface::Override.new :virtual_path => "wiki/date_index",
                     :name         => "replace-export-condition-in-date-index-page",
                     :replace      => "erb[silent]:contains('if User.current.allowed_to?(:export_wiki_pages, @project)')",
                     :text         => <<EOS
<% if User.current.allowed_to?(:export_wiki_pages, @project) || User.current.allowed_to?(:export_documentation_pages, @project) %>
EOS

Deface::Override.new :virtual_path => "wiki/date_index",
                     :name         => "replace-rendered-page-hierarchy-in-date-index-page",
                     :replace      => "erb[loud]:contains('render_page_hierarchy')",
                     :text         => <<EOS
<% if controller.controller_name == 'documentation' %>
  <%= render_documentation_page_hierarchy(@pages_by_parent_id, nil, :timestamp => true) %>
<% else %>
  <%= render_page_hierarchy(@pages_by_parent_id, nil, :timestamp => true) %>
<% end %>
EOS


