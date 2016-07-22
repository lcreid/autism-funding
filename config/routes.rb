Rails.application.routes.draw do
  #---- Website Root -----------------------------------------------------------
  root 'home#index'
  get 'home/index'

  get 'welcome/index'

  get 'other_resources/index'
  get 'my_profile/index'
  get 'my_profile/edit'
  patch 'my_profile/update'
  put 'my_profile/update'


  devise_for :users

  get 'forms', to: 'forms#index'

  resources :cf0925s
  resources :funded_people
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
