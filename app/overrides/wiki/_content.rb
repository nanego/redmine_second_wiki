Deface::Override.new :virtual_path => "wiki/_content",
                     :name => "replace-edit-section-links",
                     :replace => "erb[loud]:contains('edit_section_links')",
                     text: <<LINK_INDEX
  <%= textilizable content, :text, :attachments => content.page.attachments,
        :edit_section_links => (@sections_editable && {:action => 'edit', :project_id => @page.project, :id => @page.title}) %>
LINK_INDEX
