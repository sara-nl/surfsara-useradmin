Rails.application.routes.draw do
  resources :invites, only: [:index, :show, :new, :create] do
    member do
      get :verify
      post :accept
      get :accepted
      put :revoke
    end
  end

  resources :migrations, only: [:index, :new, :create] do
    get :success, on: :collection
  end

  resource :profile

  get 'splash', to: 'pages#splash'

  root 'invites#index'
end
