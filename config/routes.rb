Rails.application.routes.draw do
  resources :gifs, only: [:index, :show], path: '' do
    resources :tags, only: [:create, :destroy]
  end

  resources :tags, only: [:index, :show]

  root 'gifs#index'
end

