Rails.application.routes.draw do
  resources :invites, only: [:index, :show, :new, :create, :destroy] do
    member do
      get :verify
      post :accept
      get :accepted
    end
  end

  resource :profile

  root 'invites#index'
end
