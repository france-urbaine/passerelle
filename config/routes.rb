# frozen_string_literal: true

Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"

  devise_for :user

  resources :publishers, path: "/editeurs"
  resources :ddfips
  resources :collectivities, path: "/collectivites"

  resources :communes,     only: %i[index show edit update]
  resources :epcis,        only: %i[index show edit update]
  resources :departements, only: %i[index show edit update]
  resources :regions,      only: %i[index show edit update]

  resources :territories, only: %i[index],       path: "/territoires"
  resource  :territories, only: %i[edit update], path: "/territoires"

  root to: redirect("/editeurs")
end
