Deface::Override.new :virtual_path => "wikis/destroy",
                     :name         => "replace-condition-in-destroy-page",
                     :replace      => "erb[loud]:contains('form_tag({:controller')",
                     :text         => <<EOS
<%= form_tag({:controller => controller.controller_name == 'documentations' ? 'documentations' : 'wikis', :action => 'destroy', :id => @project}) do %>
EOS
