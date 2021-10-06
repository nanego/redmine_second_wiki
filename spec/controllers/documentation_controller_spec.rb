require "spec_helper"
require "rails_helper"
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

  let!(:documentation_page_1) { WikiPage.create(title: "Documentation", wiki_id: documentation.id, protected: true) }
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

  let!(:documentation_page_2) { WikiPage.create(title: "Another Documentation Page",
                                                wiki_id: documentation.id,
                                                parent_id: documentation_page_1.id) }
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

  it "shows document start page" do
    get :show, :params => { :project_id => 'ecookbook' }
    expect(response).to be_successful
    assert_select 'h1', :text => /First documentation page/

    # Ensure we don't have access without the right permission
    manager_role.remove_permission! :view_documentation_pages
    manager_role.add_permission! :view_wiki_pages
    get :show, :params => { :project_id => 'ecookbook' }
    expect(response).to have_http_status(:forbidden) # 403
  end

  it "forbids to see the standard wiki pages from documentation controller" do
    get :show, :params => { :project_id => 1, :id => 'Another_page' } # Wiki page, not documentation
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

  it "does not show edit sidebar link" do
    get :show, :params => { :project_id => 'ecookbook' }
    expect(response).to be_successful
    assert_select 'a[href=?]', '/projects/ecookbook/documentation/sidebar/edit', false

    # Ensure we don't have access without the right permission
    manager_role.remove_permission! :edit_documentation_pages
    manager_role.remove_permission! :protect_documentation_pages
    get :show, :params => { :project_id => 'ecookbook' }
    expect(response).to be_successful
    assert_select 'a[href=?]', '/projects/ecookbook/documentation/sidebar/edit', false
  end

  it "shows document page with name" do
    get :show, :params => { :project_id => 'ecookbook', :id => "Another Documentation Page" }
    expect(response).to be_successful
    assert_select 'h1', :text => /Another documentation page/

    # Ensure we don't have access without the right permission
    manager_role.remove_permission! :view_documentation_pages
    manager_role.add_permission! :view_wiki_pages
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

  it "shows old version with attachments" do
    page = WikiPage.find(4)
    page.update_column(:wiki_id, documentation.id)
    page.update_column(:parent_id, documentation_page_1.id)
    assert page.attachments.any?
    content = page.content
    content.text = "update"
    content.save!

    get :show, :params => { :project_id => 'ecookbook', :id => page.title, :version => '1' }
    expect(response).to be_successful
  end

  it "denies to show old version without permission" do
    manager_role.remove_permission! :view_documentation_edits
    get :show, :params => { :project_id => 'ecookbook', :id => 'Documentation', :version => '2' }
    expect(response).to have_http_status(:forbidden) # 403
  end

  it "shows redirected page" do
    WikiRedirect.create!(:wiki_id => 1, :title => 'Old_doc_title', :redirects_to => 'Another_Documentation_Page')
    expect(
      get :show, :params => { :project_id => 'ecookbook', :id => 'Old_doc_title' }
    ).to redirect_to('/projects/ecookbook/documentation/Another_Documentation_Page')
  end

  it "denies to export without permission" do
    manager_role.remove_permission! :export_documentation_pages
    get :export, :params => { :project_id => 'ecookbook' }
    expect(response).to have_http_status(:forbidden) # 403
  end

  it "can protect a page" do
    page = documentation_page_2
    expect(page).not_to be_protected
    expect(post(:protect, :params => { :project_id => 'ecookbook', :id => page.title, :protected => '1' })).to redirect_to(project_documentation_page_path(project, page.title))
    expect(page.reload).to be_protected
  end

  it "can unprotect a page" do
    page = documentation_page_1
    expect(page).to be_protected
    expect(post(:protect, :params => { :project_id => 'ecookbook', :id => page.title, :protected => '0' })).to redirect_to(project_documentation_page_path(project, page.title))
    expect(page.reload).not_to be_protected
  end

  it "renames a page with redirect" do
    expect(
      post :rename, :params => {
        :project_id => project.identifier,
        :id => documentation_page_2.title,
        :wiki_page => {
          :title => 'Another renamed documentation page',
          :redirect_existing_links => 1
        }
      }).to redirect_to({ :action => 'show', :project_id => 'ecookbook', :id => 'Another_renamed_documentation_page' })
    expect(documentation.find_page("Another Documentation Page")).to_not be_nil
    expect(documentation.find_page("Another Documentation Page", :with_redirect => false)).to be_nil
  end

  it "deletes a page without children and do not ask confirmation" do
    expect(
      delete :destroy, :params => { :project_id => project.identifier, :id => "Another Documentation Page" }
    ).to redirect_to({ :action => 'index', :project_id => 'ecookbook' })
  end

  it "creates new page with attachments" do
    assert_difference 'WikiPage.count' do
      assert_difference 'Attachment.count' do
        put :update, :params => {
          :project_id => 1,
          :id => 'New doc page',
          :parent_id => documentation_page_1.id,
          :content => {
            :comments => 'Created the page',
            :text => "h1. New doc page\n\nThis is a new page",
            :version => 0
          },
          :attachments => { '1' => { 'file' => uploaded_test_file('testfile.txt', 'text/plain') } }
        }
      end
    end
    page = documentation.find_page('New doc page')
    assert_equal 1, page.attachments.count
    assert_equal 'testfile.txt', page.attachments.first.filename
    expect(page.documentation_page?).to be_truthy
  end

end
