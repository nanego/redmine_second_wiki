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
                                                      author_id: 1) }
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

end
