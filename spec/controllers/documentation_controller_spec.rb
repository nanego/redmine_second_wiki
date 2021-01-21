require "spec_helper"
require "active_support/testing/assertions"

describe DocumentationController, type: :controller do

  render_views

  include ActiveSupport::Testing::Assertions

  fixtures :projects, :users, :email_addresses, :roles, :members, :member_roles,
           :enabled_modules, :wikis, :wiki_pages, :wiki_contents,
           :wiki_content_versions, :attachments,
           :issues, :issue_statuses, :trackers

  let!(:documentation) { Documentation.find_by(project: Project.find(1)) }
  let!(:project) { Project.find_by_identifier("ecookbook") }

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
  end

  it "shows document start page" do
    get :show, :params => { :project_id => 'ecookbook' }
    expect(response).to be_successful
    assert_select 'h1', :text => /First documentation page/

    # Ensure we don't have access without the right permission
    manager_role.remove_permission! :view_documentation_pages
    get :show, :params => { :project_id => 'ecookbook' }
    expect(response).to have_http_status(:forbidden) # 403
  end

  it "shows the export link" do
    # manager_role.add_permission! :export_documentation_pages
    get :show, :params => { :project_id => 'ecookbook' }
    expect(response).to be_successful
    assert_select 'a[href=?]', '/projects/ecookbook/documentation/Documentation.txt'

    # Ensure we don't have access without the right permission
    manager_role.remove_permission! :export_documentation_pages
    get :show, :params => { :project_id => 'ecookbook' }
    expect(response).to be_successful
    assert_select 'a[href=?]', '/projects/ecookbook/documentation/Documentation.txt', false
  end

  it "shows document page with name" do
    get :show, :params => { :project_id => 'ecookbook', :id => 'Another_Documentation_Page' }
    expect(response).to be_successful
    assert_select 'h1', :text => /Another documentation page/

    # Ensure we don't have access without the right permission
    manager_role.remove_permission! :view_documentation_pages
    get :show, :params => { :project_id => 'ecookbook', :id => 'Another_Documentation_Page' }
    expect(response).to have_http_status(:forbidden) # 403
  end

  it "shows old version" do
    with_settings :default_language => 'en' do
      get :show, :params => { :project_id => 'ecookbook', :id => 'Documentation', :version => '2' }
    end
    expect(response).to be_successful

    assert_select 'a[href=?]', '/projects/ecookbook/documentation/Documentation/1', :text => /Previous/
    assert_select 'a[href=?]', '/projects/ecookbook/documentation/Documentation/2/diff', :text => /diff/
    assert_select 'a[href=?]', '/projects/ecookbook/documentation/Documentation/3', :text => /Next/
  end

end
