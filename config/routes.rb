Rails.application.routes.draw do
  # get 'invoices/new'

  #  get 'static/non_supported'

  get 'static/contact_us'

  get 'static/bc_instructions'

  #---- Website Root -----------------------------------------------------------
  root 'home#index'
  get 'home/index'
  post 'home/set_panel_state'
  #  post 'home/acknowledge_bc_instructions'

  get 'welcome/index'

  get 'other_resources/index'
  #  get 'my_profile/index'
  get 'my_profile/edit'
  patch 'my_profile/update'
  put 'my_profile/update'

  devise_for :users

  get 'forms', to: 'forms#index'

  # A route to support the query of RTPs that match a new or existing invoice.
  # It has to be before the rest of the routes for invoices.
  get 'invoices/rtps'

  resources :funded_people, shallow: true do
    get :all_forms
    #    get :all_invoices
    resources :cf0925s
    resources :invoices
    resources :filled_in_forms
  end

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
