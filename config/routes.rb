Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
      root to: 'dashboard#index'
      resources :dashboard
      post 'redeem' => 'dashboard#redeem'
      post 'grant' => 'dashboard#grant'
end
