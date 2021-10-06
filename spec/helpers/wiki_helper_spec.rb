require "spec_helper"

describe WikiHelper do
  include WikiHelper
  include Rails.application.routes.url_helpers

  fixtures :projects, :users,
           :roles, :member_roles, :members,
           :enabled_modules, :wikis, :wiki_pages

  let!(:documentation) { Documentation.find_by(project: Project.find(1)) }

  describe 'Wiki Helper Patch' do

    it "should link to documentation index page when using documentation_page_edit_cancel_path for new page without parent" do
      page = WikiPage.new(:wiki => documentation)
      expect(documentation_page_edit_cancel_path(page)).to eq '/projects/ecookbook/documentation/index'
    end

    it "should link to parent documentation when using documentation_page_edit_cancel_path for new page with parent" do
      page = WikiPage.new(:wiki => documentation, :parent => documentation.find_page('Another_page'))
      expect(documentation_page_edit_cancel_path(page)).to eq '/projects/ecookbook/documentation/Another_page'
    end

    it "should link to current page when using documentation_page_edit_cancel_path for existing page" do
      page = documentation.find_page('Child_1')
      expect(documentation_page_edit_cancel_path(page)).to eq '/projects/ecookbook/documentation/Child_1'
    end

  end
end
