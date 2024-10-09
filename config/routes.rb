Rails.application.routes.draw do
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  root to: 'tasks#index'
 
  post "/webhook", to: "home#webhook"

  get "/c5ce77bc699a12d539dfbb0da6cc34054408d30d3ceed95bb840dc609bf06f79429bf3ce01464bc99e7ee938b9d0a3062f8a", to: "home#abc"

  get "/complete_task", to: "tasks#complete_task"

  get "/submitted_tasks", to: "tasks#submitted_tasks"

  get "/tasks_history", to: "tasks#tasks_history"

  post 'webhooks/telegram', to: 'telegram_webhooks#receive'

  get '/start/:code', to: "home#magic_login"

  get "/profile", to: "tasks#profile"

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
    end
    member do 
      get :task_details
      post :update_task_details
    end
  end
end
