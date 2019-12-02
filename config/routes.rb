Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root 'api#wakeup'
  get '/brent', to: 'api#brent'
  get '/all', to: 'api#all'
  get '/trends', to: 'api#trends'
end
