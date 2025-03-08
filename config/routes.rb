Rails.application.routes.draw do
  get "activities/index"
  get "users/show"
  get "pages/home"
  devise_for :users, controllers: {
    registrations: "users/registrations"
  }
  get "vacancies/index"
  get "vacancies/show"
  get "vacancies/new"
  get "vacancies/create"
  get "vacancies/edit"
  get "vacancies/update"
  get "vacancies/destroy"
  root "pages#home"
  resources :vacancies
  resources :users, only: [ :show, :index, :edit, :update ] do
    resources :sections do
      member do
        patch :move_up
        patch :move_down
        patch :batch_update
      end
      resources :cards do
        member do
          patch :update_size
        end
        collection do
          post :prepare_image
        end
      end
    end
    member do
      patch :upload_avatar
      patch :update_name
      patch :update_bio
      patch :update_job
    end
  end
  resource :wrapped, only: [ :show ] do
    get :generate, on: :member
  end
  resources :activities, only: [ :index ] do
    resources :reactions, only: [ :create ]
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
end
