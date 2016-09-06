Rails.application.routes.draw do
  resources :invites
  root 'invites#index'
end
