# frozen_string_literal: true

Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"

  mount Lookbook::Engine, at: "/lookbook" if Rails.env.development?

  concern :removable do
    get    :remove,      on: :member
    get    :remove_all,  on: :collection, path: "remove"
    delete :destroy_all, on: :collection, path: "/", as: nil
  end

  concern :removable_one do
    get :remove, on: :member
  end

  concern :undiscardable do
    patch :undiscard,     on: :member
    patch :undiscard_all, on: :collection, path: "undiscard"
  end

  devise_for :user

  ID_REGEXP = %r{(?!(new|edit|remove|discard|undiscard))[^/]+}

  constraints(id: ID_REGEXP) do
    resources :ddfips,         concerns: %i[removable undiscardable]

    resources :users,          concerns: %i[removable undiscardable], path: "/utilisateurs"
    resources :publishers,     concerns: %i[removable undiscardable], path: "/editeurs"
    resources :collectivities, concerns: %i[removable undiscardable], path: "/collectivites"
    resources :offices,        concerns: %i[removable undiscardable], path: "/guichets" do
      resource  :communes, controller: :office_communes, only: %i[edit update]
      resource  :users, controller: :office_users, only: %i[edit update], path: "/utilisateurs"
      resources :users, controller: :office_users, only: %i[destroy], concerns: %i[removable_one], path: "/utilisateurs"
    end

    resources :communes,     only: %i[index show edit update]
    resources :epcis,        only: %i[index show edit update]
    resources :departements, only: %i[index show edit update]
    resources :regions,      only: %i[index show edit update]

    resources :organizations, only: %i[index],       path: "/organisations"
    resources :territories,   only: %i[index],       path: "/territoires"
    resource  :territories,   only: %i[edit update], path: "/territoires"

    resources :user_services, only: %i[index]
  end

  root to: redirect("/editeurs")
end
