require 'application_helper'

module RedmineSecondWiki
  module ApplicationHelperPatch

    # Copied from standard method: render_page_hierarchy
    def render_documentation_page_hierarchy(pages, node = nil, options = {})
      content = +''
      if pages[node]
        content << "<ul class=\"pages-hierarchy\">\n"
        pages[node].each do |page|
          content << "<li>"
          if controller.controller_name == 'wiki' && controller.action_name == 'export'
            href = "##{page.title}"
          else
            ##############
            ## START PATCH
            href = { :controller => 'documentation', :action => 'show', :project_id => page.project, :id => page.title, :version => nil }
            ## END PATCH
            ##############
          end
          content << link_to(h(page.pretty_title), href,
                             :title => (options[:timestamp] && page.updated_on ? l(:label_updated_time, distance_of_time_in_words(Time.now, page.updated_on)) : nil))
          ##############
          ## START PATCH
          content << "\n" + render_documentation_page_hierarchy(pages, page.id, options) if pages[page.id]
          ## END PATCH
          ##############
          content << "</li>\n"
        end
        content << "</ul>\n"
      end
      content.html_safe
    end

    # Wiki links
    #
    # Examples:
    #   [[mypage]]
    #   [[mypage|mytext]]
    # wiki links can refer other project wikis, using project name or identifier:
    #   [[project:]] -> wiki starting page
    #   [[project:|mytext]]
    #   [[project:mypage]]
    #   [[project:mypage|mytext]]
    def parse_wiki_links(text, project, obj, attr, only_path, options)
      text.gsub!(/(!)?(\[\[([^\n\|]+?)(\|([^\n\|]+?))?\]\])/) do |m|
        link_project = project
        esc, all, page, title = $1, $2, $3, $5
        if esc.nil?
          page = CGI.unescapeHTML(page)
          if page =~ /^\#(.+)$/
            anchor = sanitize_anchor_name($1)
            url = "##{anchor}"
            next link_to(title.present? ? title.html_safe : h(page), url, :class => 'wiki-page')
          end

          if page =~ /^([^\:]+)\:(.*)$/
            identifier, page = $1, $2
            link_project = Project.find_by_identifier(identifier) || Project.find_by_name(identifier)
            title ||= identifier if page.blank?
          end

          if link_project && link_project.wiki && (User.current.allowed_to?(:view_wiki_pages, link_project) || User.current.allowed_to?(:view_documentation_pages, link_project))
            # extract anchor
            anchor = nil
            if page =~ /^(.+?)\#(.+)$/
              page, anchor = $1, $2
            end
            anchor = sanitize_anchor_name(anchor) if anchor.present?
            # check if page exists
            wiki_page = link_project.wiki.find_page(page)
            url =
              if anchor.present? && wiki_page.present? &&
                (obj.is_a?(WikiContent) || obj.is_a?(WikiContentVersion)) &&
                obj.page == wiki_page
                "##{anchor}"
              else
                case options[:wiki_links]
                when :local
                  "#{page.present? ? Wiki.titleize(page) : ''}.html" + (anchor.present? ? "##{anchor}" : '')
                when :anchor
                  # used for single-file wiki export
                  "##{page.present? ? Wiki.titleize(page) : title}" + (anchor.present? ? "_#{anchor}" : '')
                else
                  wiki_page_id = page.present? ? Wiki.titleize(page) : nil
                  parent =
                    if wiki_page.nil? && obj.is_a?(WikiContent) &&
                      obj.page && project == link_project
                      obj.page.title
                    else
                      nil
                    end

                  ############
                  # START PATCH

                  if wiki_page&.documentation_page? || controller.try(:controller_name) == 'documentation'
                    targeted_controller = 'documentation'
                  else
                    targeted_controller = 'wiki'
                  end
                  url_for(:only_path => only_path, :controller => targeted_controller,
                          :action => 'show', :project_id => link_project,
                          :id => wiki_page_id, :version => nil, :anchor => anchor,
                          :parent => parent)

                  # END PATCH
                  ############

                end
              end
            link_to(title.present? ? title.html_safe : h(page),
                    url, :class => ('wiki-page' + (wiki_page ? '' : ' new')))
          else
            # project or wiki doesn't exist
            all
          end
        else
          all
        end
      end
    end

  end
end

module ApplicationHelper

  prepend RedmineSecondWiki::ApplicationHelperPatch

  RECORD_LINK['WikiPage'] = lambda do |wiki_page|
    if wiki_page.try(:documentation_page?)
      link = project_documentation_page_path(wiki_page.project, wiki_page.title)
    else
      link = project_wiki_page_path(wiki_page.project, wiki_page.title)
    end
    link_to(wiki_page.pretty_title, link)
  end

end
