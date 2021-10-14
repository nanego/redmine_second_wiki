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
      options_for_select = wiki_page_options_for_select(@wiki.documentation_pages - @page.self_and_descendants, @page.parent)
    else
      options_for_select = content_tag('option', '', :value => '') + wiki_page_options_for_select(@wiki.pages.includes(:parent).to_a - @wiki.documentation_pages - @page.self_and_descendants, @page.parent)
    end
%>
<%= fp.select :parent_id, options_for_select %>
PARENT_PAGES

Deface::Override.new :virtual_path => "wiki/edit",
                     :name         => "replace-preview-link",
                     :replace      => "erb[loud]:contains('preview_project_wiki_page_path')",
                     :text         => <<PREVIEW_LINK
<%  if controller.controller_name == 'documentation'
      link = preview_project_documentation_page_path(:project_id => @project, :id => @page.title)
    else
      link = preview_project_wiki_page_path(:project_id => @project, :id => @page.title)
    end
%>
<%= wikitoolbar_for 'content_text', link %>
PREVIEW_LINK
