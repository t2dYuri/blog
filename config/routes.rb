Rails.application.routes.draw do

  root   'welcome#index'
  get    'help'    => 'welcome#help'
  get    'about'   => 'welcome#about'
  get    'contact' => 'welcome#contact'

  get    'login'   => 'sessions#new'
  post   'login'   => 'sessions#create'
  delete 'logout'  => 'sessions#destroy'

  resources :articles do
    resources :comments, only: [:create, :destroy]
  end

  get    'signup'  => 'users#new'

  resources :users
  resources :account_activations, only: [:edit]
  resources :password_resets,     only: [:new, :create, :edit, :update]
  resources :relationships,       only: [:create, :destroy]

  # resources :users do
  # member do
  #   get :following, :followers
  # end
  # end
end
