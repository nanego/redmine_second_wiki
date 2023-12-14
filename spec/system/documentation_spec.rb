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

  it "allows to update the documentation root page" do
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
  end

  it "allows to update a renamed page" do
    visit '/projects/ecookbook/documentation'
    click_on 'Save'

    expect(page).to have_current_path('/projects/ecookbook/documentation/Documentation')

    find("#content").find("span.icon-actions").click
    find("a.icon-add").click
    fill_in 'Title', :with => "New doc page"
    click_on 'Next'

    expect(page).to have_current_path('/projects/ecookbook/documentation/New_doc_page?parent=Documentation')
    fill_in 'content[text]', :with => %{# Documentation

content}
    click_on 'Save'

    visit '/projects/ecookbook/documentation/New_doc_page/rename'
    fill_in 'Title', :with => "New Title"
    click_on 'Rename'

    expect(page).to have_current_path('/projects/ecookbook/documentation/New_Title')
  end

  pending 'does not allow to rename the documentation root page'

  it "forbids to see and edit a wiki without permissions" do
    visit '/projects/ecookbook/wiki'
    expect(page).to have_selector("h2", text: "403") # Forbidden

    visit '/projects/ecookbook/wiki/Another_page/edit'
    expect(page).to have_selector("h2", text: "403") # Forbidden

    visit '/projects/ecookbook/documentation/Another_page'
    expect(page).to have_selector("h2", text: "403") # Forbidden

    visit '/projects/ecookbook/documentation/Another_page/edit'
    expect(page).to have_selector("h2", text: "403") # Forbidden

    visit '/projects/ecookbook/documentation/New_page_not_persisted'
    expect(page).to have_selector("h2", text: "New page not persisted") # New page, OK
  end

  # Before this correction, the user cannot see the image, delete it, or modify it
  it "shows both icons to edit and delete attachment when the user has the permissions(view, delete, edit) on documentation" do
    visit '/projects/ecookbook/documentation'
    click_on 'Save'

    expect(page).to have_current_path('/projects/ecookbook/documentation/Documentation')
    Attachment.find(10).update_attribute(:container, WikiPage.last)

    visit '/projects/ecookbook/documentation/Documentation'

    find("legend[class='icon icon-collapsed']").click

    expect(page).to have_css("a[class='icon-only icon-edit']")
    expect(page).to have_css("a[class='delete icon-only icon-del']")
  end

  it "shows both icons to edit and delete attachment when the user has the permissions(view, delete, edit) on wiki and no longer has permissions on the documentation" do

    manager_role = Role.find(1)
    [:view_wiki_pages,
     :view_wiki_edits,
     :export_wiki_pages,
     :edit_wiki_pages,
     :rename_wiki_pages,
     :delete_wiki_pages,
     :delete_wiki_pages_attachments,
     :protect_wiki_pages,
     :manage_wiki].each do |permission|
      manager_role.add_permission!(permission)
    end

    # add a documentation
    visit '/projects/ecookbook/documentation'
    click_on 'Save'

    # disable module of documentation
    Project.find(1).disable_module!(:documentation)

    visit '/projects/ecookbook/wiki'

    expect(page).to have_current_path('/projects/ecookbook/wiki')

    find("legend[class='icon icon-collapsed']").click

    expect(page).to have_css("a[class='icon-only icon-edit']")
    expect(page).to have_css("a[class='delete icon-only icon-del']")

  end

  it "shows a link collapse_all/expand_all in action menu" do
    manager_role = Role.find(1)
    [:view_wiki_pages,
     :view_wiki_edits,
     :export_wiki_pages,
     :edit_wiki_pages,
     :rename_wiki_pages,
     :delete_wiki_pages,
     :delete_wiki_pages_attachments,
     :protect_wiki_pages,
     :manage_wiki].each do |permission|
      manager_role.add_permission!(permission)
    end

    visit '/projects/ecookbook/wiki'

    find("#content").find("a.icon-edit").click

    expect(page).to have_current_path('/projects/ecookbook/wiki/CookBook_documentation/edit')
    fill_in 'content[text]', :with => "{{collapse(View details...)
This is a block of text that is collapsed by default.
It can be expanded by clicking a link.
}}
{{collapse(View details...)
This is a block of text that is collapsed by default.
It can be expanded by clicking a link.
}}"
    click_on 'Save'

    expect(page).to have_current_path('/projects/ecookbook/wiki/CookBook_documentation')
    expect(page).to have_css(".icon-actions")
    find(".icon-actions").click

    expect(page).to have_css(".icon-wiki-collapsed", :text => "Expand all")
    if Redmine::VERSION::MAJOR >= 5
      expect(page).to have_css("[id^=collapse].icon-expanded.collapsible", :visible => false)
    else
      expect(page).to have_css("[id^=collapse].icon-expended.collapsible", :visible => false)
    end
    expect(page).to have_css("[id^=collapse].icon-collapsed.collapsible", :visible => true)

    find(".icon-wiki-collapsed", :text => "Expand all").click

    if Redmine::VERSION::MAJOR >= 5
      expect(page).to have_css("[id^=collapse].icon-expanded.collapsible", :visible => true)
    else
      expect(page).to have_css("[id^=collapse].icon-expended.collapsible", :visible => true)
    end
    expect(page).to have_css("[id^=collapse].icon-collapsed.collapsible", :visible => false)

  end
end
