# frozen_string_literal: true

Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"

  devise_for :user

  resources :regions,      only: %i[index show edit update]
  resources :departements, only: %i[index show edit update]
  resources :epcis,        only: %i[index show edit update]
  resources :communes,     only: %i[index show edit update]

  resource :territories_updates, only: %i[show create], path: "/territoires"

  root to: redirect("/communes")
end
