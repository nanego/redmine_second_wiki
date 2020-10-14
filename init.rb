Rails.application.config.to_prepare do
  require_dependency 'redmine_second_wiki/wiki_controller_patch'
  require_dependency 'redmine_second_wiki/wiki_helper_patch'
  require_dependency 'redmine_second_wiki/application_helper_patch'
  require_dependency 'redmine_second_wiki/project_patch'
end

Redmine::Plugin.register :redmine_second_wiki do

  name 'Redmine Second-Wiki, aka Documentation plugin'
  author 'Vincent ROBERT'
  description 'This is a plugin for Redmine which adds a Documentation module and provides a second wiki to projects'
  version '0.0.1'
  url 'https://github.com/nanego/redmine_second_wiki'
  author_url 'https://github.com/nanego'

  project_module :documentation do
    permission :view_documentation_pages, {:documentation => [:index, :show, :special, :date_index]}, :read => true
    permission :view_documentation_edits, {:documentation => [:history, :diff, :annotate]}, :read => true
    permission :export_documentation_pages, {:documentation => [:export]}, :read => true
    permission :edit_documentation_pages, :documentation => [:new, :edit, :update, :preview, :add_attachment], :attachments => :upload
    permission :rename_documentation_pages, {:documentation => :rename}, :require => :member
    permission :delete_documentation_pages, {:documentation => [:destroy, :destroy_version]}, :require => :member
    permission :delete_documentation_pages_attachments, {}
    permission :protect_documentation_pages, {:documentation => :protect}, :require => :member
    permission :manage_documentation, {:documentations => [:edit, :destroy], :documentation => :rename}, :require => :member
  end

end

Redmine::MenuManager.map :project_menu do |menu|
  menu.push :documentation, { :controller => 'documentation', :action => 'show', :id => nil }, :param => :project_id,
            # :if => Proc.new { |p| p.documentation && !p.documentation.new_record? },
            :before => :wiki
end
