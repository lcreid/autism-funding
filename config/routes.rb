Rails.application.routes.draw do
  #---- Website Root -----------------------------------------------------------
  root 'home#index'
  get 'home/index'

  get 'welcome/index'

  get 'other_resources/index'
  get 'my_profile/index'

  devise_for :users

  get 'forms', to: 'forms#index'

  resources :funded_people, shallow: true do
    resources :cf0925s
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
