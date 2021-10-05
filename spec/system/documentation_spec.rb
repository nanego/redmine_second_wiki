require "spec_helper"
require "active_support/testing/assertions"

def log_user(login, password)
  visit '/my/page'
  expect(current_path).to eq '/login'

  if Redmine::Plugin.installed?(:redmine_scn)
    click_on("ou s'authentifier par login / mot de passe")
  end

  within('#login-form form') do
    fill_in 'username', with: login
    fill_in 'password', with: password
    find('input[name=login]').click
  end
  expect(current_path).to eq '/my/page'
end

RSpec.describe "creating an issue", type: :system do
  include ActiveSupport::Testing::Assertions

  fixtures :projects,
           :users, :email_addresses,
           :roles,
           :members,
           :member_roles,
           :trackers,
           :projects_trackers,
           :enabled_modules,
           :wikis,
           :wiki_pages,
           :wiki_contents

  before do
    log_user('jsmith', 'jsmith')
    Project.find(1).enable_module!(:documentation)
    manager_role = Role.find(1)
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

  it "allows to update a renamed page" do
    visit '/projects/ecookbook/documentation'
    click_on 'Save'

    expect(page).to have_current_path('/projects/ecookbook/documentation/Documentation')

    find("#content").find("a.icon-edit").click
    expect(page).to have_current_path('/projects/ecookbook/documentation/Documentation/edit')
    fill_in 'content[text]', :with => %{# Documentation

content}
    click_on 'Save'

    expect(page).to have_current_path('/projects/ecookbook/documentation/Documentation')
    expect(page).to have_selector("li", text: "Documentation")

    visit '/projects/ecookbook/documentation/Documentation/rename'
    fill_in 'Title', :with => "New Title"
    click_on 'Rename'

    expect(page).to have_current_path('/projects/ecookbook/documentation/New_Title')

  end

end
