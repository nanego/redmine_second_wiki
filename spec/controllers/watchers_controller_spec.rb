require "spec_helper"

describe WatchersController, type: :controller do
  render_views

  fixtures :projects, :users, :email_addresses, :roles, :members, :member_roles,
           :enabled_modules, :wikis, :wiki_pages, :wiki_contents,
           :wiki_content_versions, :attachments,
           :issues, :issue_statuses, :trackers

  let!(:documentation) { Documentation.find_by(project: Project.find(1)) }
  let!(:project) { Project.find_by_identifier("ecookbook") }

  let!(:wiki_page_1) { WikiPage.find(1) }

  let!(:documentation_page_1) { WikiPage.create(title: "Documentation", wiki_id: documentation.id) }
  let!(:documentation_content_1) { WikiContent.create(page_id: documentation_page_1.id,
                                                      text: "h1. First documentation page",
                                                      author_id: 1, version: 3) }
  let!(:documentation_content_version_1) {
    WikiContentVersion.create(page_id: documentation_page_1.id, version: 1, author_id: 2,
                              wiki_content_id: documentation_content_1.id,
                              data: "h1. First documentation page (version 1)") }
  let!(:documentation_content_version_2) {
    WikiContentVersion.create(page_id: documentation_page_1.id, version: 2, author_id: 1,
                              wiki_content_id: documentation_content_1.id,
                              data: "h1. First documentation page (version 2)") }
  let!(:documentation_content_version_3) {
    WikiContentVersion.create(page_id: documentation_page_1.id, version: 3, author_id: 1,
                              wiki_content_id: documentation_content_1.id,
                              data: "h1. First documentation page (version 3)") }

  let!(:documentation_page_2) { WikiPage.create(title: "Another Documentation Page", wiki_id: documentation.id) }
  let!(:documentation_content_2) { WikiContent.create(page_id: documentation_page_2.id,
                                                      text: "h1. Another documentation page",
                                                      author_id: 1, version: 3) }
  let!(:manager_role) { Role.find(1) }

  before do
    User.current = User.find(2) #jsmith
    @request.session[:user_id] = 2
    Setting.default_language = 'en'

    documentation.update_attribute(:documentation_start_page, "Documentation")
    project.enable_module!(:documentation)

    [:view_documentation_pages,
     :view_documentation_edits,
     :export_documentation_pages,
     :edit_documentation_pages,
     :rename_documentation_pages,
     :delete_documentation_pages,
     :delete_documentation_pages_attachments,
     :protect_documentation_pages,
     :manage_documentation].each do |permission|
      manager_role.add_permission!(permission)
    end

    [:view_wiki_pages,
     :view_wiki_edits,
     :export_wiki_pages,
     :edit_wiki_pages,
     :rename_wiki_pages,
     :delete_wiki_pages,
     :delete_wiki_pages_attachments,
     :protect_wiki_pages,
     :manage_wiki].each do |permission|
      manager_role.remove_permission!(permission)
    end
  end

  it "allows to watch a documentation page" do
    expect {
      post :watch, :params => { :object_type => 'wiki_page', :object_id => documentation_page_1.id }, :xhr => true
      expect(response).to be_successful
      expect(response.body).to include("$(\".wiki_page-#{documentation_page_1.id}-watcher\")")
    }.to change(Watcher, :count)
    expect(documentation_page_1).to be_watched_by(User.find(2))
  end

  it "DOES NOT allow to watch a wiki page without permission" do
    expect {
      post :watch, :params => { :object_type => 'wiki_page', :object_id => wiki_page_1.id }, :xhr => true
      expect(response).to have_http_status(:forbidden) # 403
    }.not_to change(Watcher, :count)
    expect(wiki_page_1).not_to be_watched_by(User.find(2))
  end

end

