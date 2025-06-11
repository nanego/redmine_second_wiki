Deface::Override.new :virtual_path => "wiki/show",
                     :name => "replace-url-for-new-wiki-link",
                     :replace => "erb[silent]:contains('User.current.allowed_to?(:edit_wiki_pages, @project)')",
                     :closing_selector => "erb[silent]:contains('end')",
                     :text => <<LINK
<% if controller.controller_name == 'documentation' %>
  <% if User.current.allowed_to?(:edit_documentation_pages, @project) %>
    <%= link_to l(:label_documentation_page_new), 
      new_project_documentation_page_path(@project, :parent => @page.title), 
      remote: true,
      class: 'icon icon-add' %>
  <% end %>
<% else %>
  <% if User.current.allowed_to?(:edit_wiki_pages, @project) %>
    <%= link_to l(:label_wiki_page_new), 
      new_project_wiki_page_path(@project, :parent => @page.title), 
      remote: true,
      class: 'icon icon-add' %>
  <% end %>
<% end %>
LINK

Deface::Override.new :virtual_path => "wiki/show",
                     :name => "adapt-export-wiki-permissions",
                     :replace => "erb[silent]:contains('User.current.allowed_to?(:export_wiki_pages, @project)')",
                     :partial => "documentation/export_links"

Deface::Override.new :virtual_path => "wiki/show",
                     :name => "adapt-link-to-diff",
                     :replace => "erb[loud]:contains('l(:label_diff)')",
                     :text => <<EOS
<%= link_to l(:label_diff), :action => 'diff',
  :id => @page.title, :project_id => @page.project,
  :version => @content.version %>
EOS

Deface::Override.new :virtual_path => "wiki/show",
                     :name => "adapt-add-attachment-form",
                     :replace => "erb[loud]:contains('form_tag')",
                     :text => <<FORM_TAG
    <%= form_tag({:controller => controller.controller_name, :action => 'add_attachment',
                  :project_id => @project, :id => @page.title},
                 :multipart => true, :id => "add_attachment_form") do %>
FORM_TAG

Deface::Override.new :virtual_path  => "wiki/show",
                     :name          => "add_link_collapse",
                     :insert_before => "erb[loud]:contains(\"l(:button_delete)\")",
                     :text          => <<EXPAND_COLLAPSE
  <%= link_to l(:button_expand_all), "#", :onclick => "toggle_expand_collapse_all_wiki(this); return false;", :class => 'icon icon-wiki-collapsed collapsible' %>
EXPAND_COLLAPSE

Deface::Override.new :virtual_path  => "wiki/show",
                     :name          => "add_function_toggle_collapse_expended",
                     :insert_bottom => "div.contextual",
                     :text          => <<SCRIPT_FUNCTION
<script type="text/javascript"> 
  function toggle_expand_collapse_all_wiki(ele){    
    $(ele).toggleClass('icon-wiki-collapsed icon-wiki-expended')
    let collapse = $('[id^=collapse].icon-collapsed.collapsible:visible');
    if (collapse.length > 0) {
      collapse.each(function( index ) {
        $(this).click();
      });
      $(ele).text('<%= l(:button_collapse_all)%>');

      return;
    } 
    
    let expended = $('[id^=collapse].icon-expanded.collapsible:visible'); 
    if (expended == undefined) {
      let expended = $('[id^=collapse].icon-expended.collapsible:visible'); // Redmine 4 compatibility: icon-expended was renamed to icon-expanded in Redmine 5
    }
    if (expended.length > 0) {
      expended.each(function( index ) {
        $(this).click();
      });
      $(ele).text('<%= l(:button_expand_all)%>');
      
      return;
    }
  } 
</script>
SCRIPT_FUNCTION
