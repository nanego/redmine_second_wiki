Deface::Override.new :virtual_path => "wiki/_new_modal",
                     :name         => "replace-url-to-documentation",
                     :replace      => "erb[loud]:contains('labelled_form_for :page')",
                     :text         => <<LINK
<%= labelled_form_for :page, @page,
            :url => controller.controller_name == 'documentation' ? new_project_documentation_page_path(@project) : new_project_wiki_page_path(@project),
            :method => 'post',
            :remote => true do |f| %>
LINK
