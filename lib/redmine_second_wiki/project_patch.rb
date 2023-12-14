require 'project'

module RedmineSecondWiki
  module ProjectPatch
    def self.prepended(base)
      base.class_eval do
        has_one :documentation, :dependent => :destroy
      end
    end
  end
end
Project.prepend RedmineSecondWiki::ProjectPatch
