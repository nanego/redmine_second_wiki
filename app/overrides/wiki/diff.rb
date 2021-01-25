Deface::Override.new :virtual_path => "wiki/diff",
                     :name         => "replace-title-in-history-diffs",
                     :replace      => "erb[loud]:contains('title [@page.pretty_title, project_wiki_page_path')",
                     :partial         => "documentation/diff_title"
