Rubytime::Application.routes.draw do
  resources :projects
  
  resources :users do
    collection do
      get :request_password
      post :do_request_password
    end
  end
  
  resource :sessions
  
  resources :activities do
    collection do
      get :calendar, :missed, :export
      post :search, :invoice, :day_off
      delete :revert_day_off
    end
  end
  
  resources :projects do
    resources :hourly_rates
  end
  
  resources :invoices
  resources :clients
  resources :roles
  resources :currencies
  resources :settings
  
  root :to => 'activities#index'
  
  match '/logout' => 'sessions#destroy', :as => :logout
  match '/login' => 'sessions#new', :as => :login
  match '/register' => 'users#create', :as => :register
  match '/signup' => 'users#new', :as => :signup
  match '/reset/:key' => 'users#reset', :as => :reset
end
