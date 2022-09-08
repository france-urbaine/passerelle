# frozen_string_literal: true

Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"

  concern :removable do
    get    :remove,      on: :member
    get    :remove_all,  on: :collection, path: "remove"
    delete :destroy_all, on: :collection, path: "/", as: nil
  end

  concern :undiscardable do
    patch  :undiscard,      on: :member
    patch  :undiscard_all,  on: :collection, path: "undiscard"
  end

  devise_for :user

  resources :ddfips,         concerns: %i[removable undiscardable]

  resources :users,          concerns: %i[removable undiscardable], path: "/utilisateurs"
  resources :publishers,     concerns: %i[removable undiscardable], path: "/editeurs"
  resources :collectivities, concerns: %i[removable undiscardable], path: "/collectivites"
  resources :services,       concerns: %i[removable undiscardable], path: "/guichets" do
    resource :users,    controller: :services_users,    only: %i[edit update], path: "/utilisateurs"
    resource :communes, controller: :services_communes, only: %i[edit update]
  end

  resources :communes,     only: %i[index show edit update]
  resources :epcis,        only: %i[index show edit update]
  resources :departements, only: %i[index show edit update]
  resources :regions,      only: %i[index show edit update]

  resources :organizations, only: %i[index],       path: "/organisations"
  resources :territories,   only: %i[index],       path: "/territoires"
  resource  :territories,   only: %i[edit update], path: "/territoires"

  resources :user_services, only: %i[index]

  root to: redirect("/editeurs")
end
