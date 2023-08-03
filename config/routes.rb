Rails.application.routes.draw do
  root "home#index"

  get 'login',     to: "home#login"
  get 'logout',    to: "home#logout"
  get 'authorize', to: "home#authorize"
end
