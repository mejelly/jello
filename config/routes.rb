Rails.application.routes.draw do

  resources :translations
  resources :articles
  root 'landing_page#home'
  get 'dashboard' => 'dashboard#show'
  get '/auth/auth0/callback' => 'auth0#callback'
  get '/auth/failure'        => 'auth0#failure'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
