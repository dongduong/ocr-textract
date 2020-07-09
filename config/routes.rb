Rails.application.routes.draw do
  root 'accident_invoice#index'

  get 'dashboard/index'
  get 'ocr/index'

  resources :accident_invoice

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
