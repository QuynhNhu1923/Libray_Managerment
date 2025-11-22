Rails.application.routes.draw do
  scope "(:locale)", locale: /en|vi/ do
    root "static_pages#home"

    get "/home",    to: "static_pages#home",    as: :home
    get "/help",    to: "static_pages#help",    as: :help
    get "/contact", to: "static_pages#contact", as: :contact

    get "signup",   to: "users#new",            as: :signup
    post "signup",  to: "users#create"        

    get "login",    to: "sessions#new",         as: :login
    post "login",   to: "sessions#create"
    delete "logout",to: "sessions#destroy",     as: :logout

    resources :users
    resources :account_activations, only: :edit
    resources :password_resets, only: %i(new create edit update)
  end
end
