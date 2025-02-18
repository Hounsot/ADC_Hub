Rails.application.routes.draw do
  get "cards/new"
  get "cards/edit"
  get "cards/create"
  get "cards/update"
  get "cards/destroy"
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
    resources :cards, only: [ :create, :update, :destroy ] do
      patch :update_size, on: :member
    end
    member do
      patch :upload_avatar
      patch :update_name
      patch :update_bio
    end
  end
  resource :wrapped, only: [ :show ] do
    get :generate, on: :member
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
