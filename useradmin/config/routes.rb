Rails.application.routes.draw do
  resources :invites, only: [:index, :show, :new, :create] do
    member do
      get :verify
      post :accept
      get :accepted
      put :revoke
    end
  end

  resources :migrations, only: [:new, :create] do
    get :success, on: :collection
  end

  resource :profile

  root 'invites#index'
end
