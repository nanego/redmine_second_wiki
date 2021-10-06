class AddDocumentationStartPageToWikis < ActiveRecord::Migration[5.2]
  def self.up
    add_column :wikis, :documentation_start_page, :string, :default => "Documentation"
  end

  def self.down
    remove_column :wikis, :documentation_start_page
  end
end
