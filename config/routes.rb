Rails.application.routes.draw do
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  root to: 'tasks#index'
 
  post "/webhook", to: "home#webhook"

  post "/yahoo", to: "home#yahoo"

  get "/c5ce77bc699a12d539dfbb0da6cc34054408d30d3ceed95bb840dc609bf06f79429bf3ce01464bc99e7ee938b9d0a3062f8a", to: "home#abc"

  get "/complete_task", to: "tasks#complete_task"

  get "/submitted_tasks", to: "tasks#submitted_tasks"

  get "/tasks_history", to: "tasks#tasks_history"

  post 'webhooks/telegram', to: 'telegram_webhooks#receive'

  get '/start/:code', to: "home#magic_login"

  get "/profile", to: "tasks#profile"

  get "/otps", to: "home#index"

  get "/yahoo", to: "home#yahoo_home"

  get "/missing", to: "home#missing"

  get "/console", to: "home#console"

  get "/rate", to: "home#rate"



  resources :tasks do
    collection do
      post :create_or_edit
      get :submissions
      get :add_files
      post :upload_file_to_task
      post :update_complete_task
      get :download_file
      get :export_csv
      post :toogle_submission
      get :update_wallet
      get :profile
      get :users
      post :bulk_toggle_payment
      post :bulk_change_status
      post :add_remarks
      post :bulk_update_status
      get :user_details
      get :available_tasks
    end
    member do 
      get :task_details
      post :update_task_details
    end
  end

  resources :webscrap do
    member do
      get :process_scraping
      post :start_scraping
      get :check_status
    end
    collection do
      get 'show_scraping_job'
      get 'get_page_content/:id', action: :get_page_content
      get 'get_page_links/:id', action: :get_page_links
      get 'view_page/:id', action: :view_page, as: :view_page
    end
  end

end
