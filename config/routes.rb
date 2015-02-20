Rails.application.routes.draw do
  resources :gifs, only: [:index, :show], path: '' do
    resources :tags, only: [:create, :destroy]
  end

  root 'gifs#index'
end

