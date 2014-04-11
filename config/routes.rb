Contributron::Application.routes.draw do
  root "home#new"

  get 'auth/:provider/callback' => 'sessions#create'
  get '/signout' => 'sessions#destroy', :as => :signout
 
end
