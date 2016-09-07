Rails.application.routes.draw do
  resources :invites, only: [:index, :show, :new, :create, :destroy]
  root 'invites#index'
end
