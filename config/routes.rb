Rails.application.routes.draw do
  #---- Website Root -----------------------------------------------------------
  root 'welcome#indexa'

#  get 'welcome/indexa' orginal
  get 'welcome/index', to: 'welcome#index'

  get 'other_resources/index'
  get 'my_profile/index'
  get 'my_profile/edit'
  patch 'my_profile/update'
  put 'my_profile/update'

  devise_for :users

  resources :cf0925s

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
