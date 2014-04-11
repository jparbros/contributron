Contributron::Application.routes.draw do

  get 'auth/:provider/callback' => 'sessions#create'

  resources :dashboard do
    get :load_closed
  end
  get '/signout' => 'sessions#destroy', :as => :signout

  root "sessions#new"
end
