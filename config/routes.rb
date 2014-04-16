require 'sidekiq/web'

Contributron::Application.routes.draw do

  get 'auth/:provider/callback' => 'sessions#create'

  resources :dashboard
  resources :members

  get '/signout' => 'sessions#destroy', :as => :signout

  root "sessions#new"

  mount Sidekiq::Web, at: "/sidekiq"
end
