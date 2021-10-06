Deface::Override.new :virtual_path => "wiki/edit",
                     :name         => "replace-cancel-link",
                     :replace      => "erb[loud]:contains('link_to l(:button_cancel)')",
                     :text         => <<CANCEL_LINK
<%= link_to l(:button_cancel), controller.controller_name == 'documentation' ? documentation_page_edit_cancel_path(@page) : wiki_page_edit_cancel_path(@page) %>
CANCEL_LINK

Deface::Override.new :virtual_path => "wiki/edit",
                     :name         => "scope-available-parent-pages",
                     :replace      => "erb[loud]:contains('fp.select :parent_id')",
                     :text         => <<PARENT_PAGES
<%  if controller.controller_name == 'documentation'
      wiki_pages = @wiki.documentation_pages
    else
      wiki_pages = @wiki.pages.includes(:parent).to_a
    end
%>
<%= fp.select :parent_id,
               wiki_page_options_for_select(
                 wiki_pages -
                 @page.self_and_descendants, @page.parent) %>
PARENT_PAGES
