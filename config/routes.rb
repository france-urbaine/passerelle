# frozen_string_literal: true

Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"

  devise_for :user

  resources :ddfips
  resources :publishers,     path: "/editeurs"
  resources :collectivities, path: "/collectivites"
  resources :users,          path: "/utilisateurs"

  resources :communes,     only: %i[index show edit update]
  resources :epcis,        only: %i[index show edit update]
  resources :departements, only: %i[index show edit update]
  resources :regions,      only: %i[index show edit update]

  resources :organizations, only: %i[index],       path: "/organisations"
  resources :territories,   only: %i[index],       path: "/territoires"
  resource  :territories,   only: %i[edit update], path: "/territoires"

  root to: redirect("/editeurs")
end
