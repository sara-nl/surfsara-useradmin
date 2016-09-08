Rails.application.routes.draw do
  resources :invites, only: [:index, :show, :new, :create, :destroy] do
    get :accept, on: :member
  end

  resource :profile

  root 'invites#index'
end
