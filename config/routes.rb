Contributron::Application.routes.draw do

  resources :dashboard do
    get :load_closed
  end
  get 'auth/:provider/callback' => 'sessions#create'
  get '/signout' => 'sessions#destroy', :as => :signout

  root "home#new"
end
