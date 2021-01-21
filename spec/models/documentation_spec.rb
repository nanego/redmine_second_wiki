require "spec_helper"

describe "Documentation" do

  fixtures :projects, :wikis

  let!(:wiki) { Wiki.find_by(project: Project.find(1)) }

  before do
    wiki.update_attribute(:documentation_start_page, "Documentation")
  end

  it "provides documentation_start_page to projects" do
    expect(wiki.start_page).to eq "CookBook documentation"
    expect(wiki.documentation_start_page).to eq "Documentation"
  end

end
