Rails.application.routes.draw do
  resources :gifs, only: [:index]
  root 'gifs#index'
end

