require 'sidekiq/web'

Rails.application.routes.draw do
  mount Sidekiq::Web, at: "sidekiq"
  mount PgHero::Engine, at: "pghero"

  get :admin, to: redirect('/admin/packages')

  namespace :admin do
    resources :packages
  end

  resources :deals

  get '/versions/recent', to: 'versions#recent', as: :recent_versions

  resources :packages do
    resources :versions
    collection do
      post :import
      get :lookup
      get :search
      get :recent
    end
  end

  get :login,  to: 'sessions#new'
  get :logout, to: 'sessions#destroy'

  scope :auth do
    match '/:provider/callback', to: 'sessions#create',  via: [:get, :post]
    match :failure,              to: 'sessions#failure', via: [:get, :post]
  end

  get '/stats', to: 'home#stats'

  root to: 'home#index'
end
