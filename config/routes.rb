Rails.application.routes.draw do
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  root to: 'tasks#index'
 
  post "/webhook", to: "home#webhook"

  get "/c5ce77bc699a12d539dfbb0da6cc34054408d30d3ceed95bb840dc609bf06f79429bf3ce01464bc99e7ee938b9d0a3062f8a", to: "home#abc"

  get "/complete_task", to: "tasks#complete_task"

  post 'webhooks/telegram', to: 'telegram_webhooks#receive'

  resources :tasks do
    collection do
      post :create_or_edit
      get :submissions
      get :add_files
      post :upload_file_to_task
      post :update_complete_task
    end
  end
end
