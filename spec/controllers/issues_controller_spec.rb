require "spec_helper"
require "active_support/testing/assertions"

describe IssuesController, type: :controller do
  render_views
  include ActiveSupport::Testing::Assertions

  fixtures :users, :email_addresses, :user_preferences,
           :roles,
           :members,
           :member_roles,
           :issues,
           :issue_statuses,
           :issue_relations,
           :versions,
           :trackers,
           :projects_trackers,
           :issue_categories,
           :enabled_modules,
           :enumerations,
           :attachments,
           :workflows,
           :custom_fields,
           :custom_values,
           :custom_fields_projects,
           :custom_fields_trackers,
           :time_entries,
           :journals,
           :journal_details,
           :queries,
           :repositories,
           :changesets,
           :projects,
           :wikis, :wiki_pages, :wiki_contents

  before do
    @request.session[:user_id] = 2
    Setting.plain_text_mail = 0
    Setting.default_language = 'en'
  end

  it "should send a notification with a link to a wiki page" do
    ActionMailer::Base.deliveries.clear

    assert_difference 'ActionMailer::Base.deliveries.size', 1 do
      assert_difference 'Issue.count' do
        post :create, params: { :project_id => 2,
                                :issue => { :tracker_id => 3,
                                            :subject => 'This is the test_new issue',
                                            :description => 'This is the description with a link to wiki page [[onlinestore:Start page]]',
                                            :priority_id => 5,
                                            :custom_field_values => { '2' => 'Value for field 2' } } }
      end
    end

    expect(response).to redirect_to(:controller => 'issues', :action => 'show', :id => Issue.last.id)

    default_mail = ActionMailer::Base.deliveries.first
    expect(default_mail['bcc'].value).to include User.find(2).mail
    html_mail = default_mail.parts[1]
    expect(html_mail.body.raw_source).to include '<a class="wiki-page"'
    expect(html_mail.body.raw_source).to include '/projects/onlinestore/wiki/Start_page'

  end

end
