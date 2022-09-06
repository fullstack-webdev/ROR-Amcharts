ElephantWebApp::Application.routes.draw do

  resources :programs, only: [:index, :new, :create, :edit, :show, :update] do
    get :autocomplete_well_name, :on => :collection
  end

  root to: 'static_pages#home'

  match '/help', to: 'static_pages#help'
  match '/solutions', to: 'static_pages#solutions', as: 'solutions'
  match '/solutions/:page', :to => 'static_pages#solutions'
  match '/content/:page', :to => 'static_pages#content'
  match '/apps', to: 'static_pages#apps'
  match '/developers', to: 'static_pages#developers'
  match '/pricing', to: 'static_pages#pricing'
  match '/team', to: 'static_pages#team'
  match '/about', to: 'static_pages#about'
  match '/contact', to: 'static_pages#contact'
  match '/overview', to: 'overview#overview', :via => :get
  match '/insight', to: 'explore#index', :via => :get
  match '/overview', to: 'overview#filter_overview', :via => :post
  match '/terms_of_use', to: 'static_pages#terms_of_use'
  match '/tutorial', to: 'static_pages#tutorial'
  match '/terms', to: 'static_pages#terms'
  match '/privacy', to: 'static_pages#privacy'
  match '/copyright', to: 'static_pages#copyright'

  match '/pusher/auth', to: 'pusher#auth'

  resources :users, only: [:index, :show, :new, :create, :destroy, :edit, :update]

  resources :user_roles, only: [:index, :show, :new, :create, :destroy, :edit, :update]

  resources :sessions, only: [:create, :destroy]

  #match "/settings" => "settings#edit", :via => :get
  #match "/settings" => "settings#update", :via => :put
  resources :settings, only: [:edit, :update, :security, :update_security]
  match '/security', to: 'settings#security'
  match '/update_security', to: 'settings#update_security'

  match '/signin', to: 'sessions#new'
  match '/is_signed_in', to: 'sessions#show'
  get '/update_password', to: 'sessions#edit'
  match '/create_password', to: 'sessions#update', via: :post
  match '/signout', to: 'sessions#destroy', via: :delete
  match '/reset_password', to: 'sessions#reset_password'
  match '/verify_network', to: 'sessions#verify_network'
  match '/authenticate_user', to: 'sessions#authenticate_user', via: :post
  match '/register_job', to: 'sessions#register_job', via: :post

  match '/new_record', to: 'sessions#new_record', via: :post


  resources :admin, only: [:index]
  match '/admin', to: 'admin#index'
  match '/admin/login', to: 'admin#signin'
  match '/admin/logout', to: 'admin#signout', via: :delete
  match '/admin/impersonate/:id', to: 'admin#impersonate'
  match '/admin/company/:id', to: 'admin#index'
  match '/admin/company/:id/users', to: 'admin_users#index'
  match '/admin/company/:id/import', to: 'csv_import#index'
  match '/admin/company/:id/settings', to: 'admin#company_settings'
  match '/admin/company/:id/warnings', to: 'admin#company_warnings'

  resources :elephant_admin, only: [:index]
  match '/elephant_admin', to: 'elephant_admin#index'

  resources :companies, only: [:new, :destroy, :create, :show, :edit, :update]

  resources :job_templates, only: [:index, :new, :create, :destroy, :show, :edit, :update]

  resources :clients, only: [:index, :new, :create, :destroy, :show, :edit, :update]

  resources :districts, only: [:index, :new, :create, :destroy, :show, :edit, :update]

  resources :countries, only: [:show]

  resources :divisions, only: [:index, :show, :new, :create, :edit, :update, :destroy]
  resources :segments, only: [:index, :show, :new, :create, :edit, :update, :destroy]
  resources :product_lines, only: [:index, :show, :new, :create, :edit, :update, :destroy]

  resources :documents, only: [:show, :new, :create, :update, :destroy]


  resources :jobs, only: [:index, :show, :new, :create, :update, :destroy] do
    member do
      get :rig
      get :offset_well
      put :set_offset_well
      get :drill_view
      get :get_torque
      get :get_ecd
      post :create_hole_string
      get :get_hole_string
      post :create_fluids
      get :get_fluids
      post :set_default_conf
      get :get_default_conf
      get :new_conf_hole_string
      get :new_conf_fluids
      get :edit_conf_hole_string
      post :delete_conf_hole_string
      post :import_bha
      post :import_survey
      get :drillview
      post :historical_upload
      post :report_upload
      get :get_drill_string_detail
      get :new_annotation
      post :create_annotation
      post :create_annotation_comment
      get :show_annotation

    end
  end

  resources :event_warnings do
    member do
      get :get_warning_detail
    end
  end

  resources :event_warning_types, :path => '/admin/warning_types'

  resources :fields, only: [:index, :show, :new, :create]

  resources :wells, only: [:index, :show, :new, :create, :edit, :update] do
    get :autocomplete_well_name, :on => :collection
    post :update_info
  end
  resources :rigs, only: [:index, :new, :create, :show, :edit, :update]

  resources :search, only: [:index]

  resources :history, only: [:index]
  resources :insight, only: [:index]

  resources :alerts, only: [:index]

  resources :job_notes, only: [:new, :create, :destroy]

  resources :job_memberships, only: [:new, :edit, :update, :create, :destroy]

  resources :job_note_comments, only: [:create, :destroy]

  resources :conversations, only: [:index, :show, :new, :create, :destroy, :update]


  resources :failures, only: [:index, :new, :show, :create, :edit, :update, :destroy]

  resources :document_shares, only: [:index, :show, :new, :create, :update, :destroy]


  resources :bhas, only: [:show, :new, :create, :edit, :update, :destroy]

  resources :issues, only: [:index, :show, :create, :edit, :update, :destroy]

  resources :surveys, only: [:index, :new, :create, :show, :edit, :update, :destroy]
  resources :survey_points, only: [:new, :create, :edit, :update, :destroy]

  resources :rig_memberships, only: [:new, :create, :destroy]

  resources :job_costs, only: [:index, :show, :new, :create, :edit, :update, :destroy]

  match '/report_status/:id', to: 'reports#status', :via => :get

  resources :survey_projections, only: [:new, :create]

  namespace :performance do
    resources :programs, only: [:index] do
      collection do
        get :get_histogram
      end
    end
    resources :rigs, only: [:index] do
      collection do
        get :get_histogram
      end
    end
    resources :wells, only: [:index] do
      collection do
        get :get_histogram
      end
    end
    resources :custom_queries, only: [:index] do
      collection do
        get :get_histogram
      end
    end
  end
  # match '/performance', to: 'performance#index'

  match '/company_features/:id', to: 'company_features#update', via: :put

  resources :lwd_logs, only: [:new, :create]

  resources :witsml_servers, only: [:index, :create, :destroy] do
      member do
          get :connected
          get :wells
          get :import
        end
  end
end

