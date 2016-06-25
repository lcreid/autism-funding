Rails.application.routes.draw do
  #---- Website Root -----------------------------------------------------------
  root 'welcome#index'

  get 'welcome/index'

  get 'other_resources/index'
  get 'my_profile/index'

  devise_for :users

  resources :cf0925s

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
