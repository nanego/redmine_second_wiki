require_dependency 'wiki_controller'

class WikiController

  append_before_action :redirect_to_show_documentation, only: [:show]

  def redirect_to_show_documentation

    # puts "redirect_to_show_documentation"
    # puts @wiki.pages.inspect

  end

end
