Rails.application.routes.draw do
  resources :tags, only: [:index, :show]

  resources :gifs, only: [:index, :show], path: '' do
    resources :tags, only: [:create, :destroy]
  end

  root 'gifs#index'
end

