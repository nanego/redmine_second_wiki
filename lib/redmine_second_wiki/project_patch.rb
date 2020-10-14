require_dependency 'project'

class Project < ActiveRecord::Base

  has_one :documentation, :dependent => :destroy

end
