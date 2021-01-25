Deface::Override.new :virtual_path => "wiki/edit",
                     :name         => "replace-cancel-link",
                     :replace      => "erb[loud]:contains('link_to l(:button_cancel)')",
                     :text         => <<CANCEL_LINK
<%= link_to l(:button_cancel), controller.controller_name == 'documentation' ? documentation_page_edit_cancel_path(@page) : wiki_page_edit_cancel_path(@page) %>
CANCEL_LINK
