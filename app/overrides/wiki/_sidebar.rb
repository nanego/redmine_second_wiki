Deface::Override.new :virtual_path => "wiki/_sidebar",
                     :name => "replace-url-to-edit-sidebar",
                     :replace => "erb[silent]:contains('User.current.allowed_to?(:edit_wiki_pages, @project)')",
                     :closing_selector => "erb[silent]:contains('end')",
                     :text => <<LINK
<% if controller.controller_name != 'documentation' && 
      User.current.allowed_to?(:edit_wiki_pages, @project) &&
      (@wiki && @wiki.find_or_new_page('Sidebar').editable_by?(User.current)) %>
  <div class="contextual">
    <%= link_to l(:button_edit), edit_project_wiki_page_path(@project, 'sidebar'),
                :class => 'icon icon-edit' %>
  </div>
<% end -%>
<% if controller.controller_name == 'documentation' &&
      User.current.allowed_to?(:edit_documentation_pages, @project) &&
      (@wiki && @wiki.find_or_new_page('Sidebar').editable_by?(User.current)) %>
  <div class="contextual">
    <%= link_to l(:button_edit), edit_project_documentation_page_path(@project, 'sidebar'),
                :class => 'icon icon-edit' %>
  </div>
<% end -%>
LINK

Deface::Override.new :virtual_path => "wiki/_sidebar",
                     :name => "replace-sidebar-h3",
                     :replace => "erb[loud]:contains('l(:label_wiki)')",
                     text: <<TITLE
<% if controller.controller_name == 'documentation' %>
  <%= l(:label_documentation) %>
<% else %>
  <%= l(:label_wiki) %>
<% end %>
TITLE

Deface::Override.new :virtual_path => "wiki/_sidebar",
                     :name => "replace-sidebar-index-by-date",
                     :replace => "erb[loud]:contains('link_to(l(:label_index_by_date)')",
                     text: <<LINK_INDEX
<%= link_to(l(:label_index_by_date),
                  {:project_id => @project,
                   :action => 'date_index'}) %>
LINK_INDEX


