require 'sidekiq/web'

Rails.application.routes.draw do
  mount Sidekiq::Web, at: "sidekiq"
  mount PgHero::Engine, at: "pghero"

  get :admin, to: redirect('/admin/packages')

  namespace :admin do
    resources :packages
  end

  resources :packages do
    resources :versions
    collection do
      post :import
      get :search
    end
  end

  get :login,  to: 'sessions#new'
  get :logout, to: 'sessions#destroy'

  scope :auth do
    match '/:provider/callback', to: 'sessions#create',  via: [:get, :post]
    match :failure,              to: 'sessions#failure', via: [:get, :post]
  end

  root to: 'home#index'
end
