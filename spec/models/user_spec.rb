require "spec_helper"

describe "User" do

  fixtures :users, :projects

  let!(:project) { Project.find(1) }
  let!(:admin) { User.find(1) }

  it "returns NOT-ALLOWED if module is disabled" do
    project.enabled_module_names = ["issue_tracking"]
    assert_equal true, admin.allowed_to?(:add_issues, project)
    assert_equal false, admin.allowed_to?(:view_wiki_pages, project)
    assert_equal false, admin.allowed_to?(:view_documentation_pages, project)
  end

  it "returns ALLOWED if module is enabled" do
    project.enabled_module_names = ["issue_tracking", "documentation"]
    assert_equal true, admin.allowed_to?(:add_issues, project)
    assert_equal false, admin.allowed_to?(:view_wiki_pages, project)
    assert_equal true, admin.allowed_to?(:view_documentation_pages, project)
  end

end
