RedmineApp::Application.routes.draw do

  match 'projects/:id/documentation/destroy', :to => 'documentations#destroy', :via => [:get, :post]

  resources :projects do
    match 'documentation/index', :controller => 'documentation', :action => 'index', :via => :get
    resources :documentation, :except => [:index, :create], :as => 'documentation_page' do
      member do
        get 'rename'
        post 'rename'
        get 'history'
        get 'diff'
        match 'preview', :via => [:post, :put, :patch]
        post 'protect'
        post 'add_attachment'
      end
      collection do
        get 'export'
        get 'date_index'
        post 'new'
      end
    end
    match 'documentation', :controller => 'documentation', :action => 'show', :via => :get
    get 'documentation/:id/:version', :to => 'documentation#show', :constraints => {:version => /\d+/}
    delete 'documentation/:id/:version', :to => 'documentation#destroy_version'
    get 'documentation/:id/:version/annotate', :to => 'documentation#annotate'
    get 'documentation/:id/:version/diff', :to => 'documentation#diff'
  end

end
