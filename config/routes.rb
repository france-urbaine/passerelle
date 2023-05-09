# frozen_string_literal: true

Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"

  mount Lookbook::Engine, at: "/lookbook" if Rails.env.development?

  concern :removable do
    get   :remove,    on: :member
    patch :undiscard, on: :member
  end

  concern :removable_collection do
    get    :remove_all,    on: :collection, path: "remove"
    patch  :undiscard_all, on: :collection, path: "undiscard"
    delete :destroy_all,   on: :collection, path: "/", as: nil
  end

  concern :updatable_collection do
    get   :edit_all,   on: :collection, path: "edit"
    patch :update_all, on: :collection, path: "/", as: nil
  end

  concern :nested_users do
    resources :users, only: %i[index new create], concerns: %i[removable_collection], path: "/utilisateurs"
  end

  devise_for :user

  ID_REGEXP = %r{(?!(new|edit|remove|discard|undiscard|offices))[^/]+}

  constraints(id: ID_REGEXP) do
    resources :publishers,     concerns: %i[removable removable_collection nested_users], path: "/editeurs"
    resources :collectivities, concerns: %i[removable removable_collection nested_users], path: "/collectivites"
    resources :ddfips,         concerns: %i[removable removable_collection nested_users]
    resources :offices,        concerns: %i[removable removable_collection], path: "/guichets" do
      resource :communes, controller: :office_communes, concerns: %i[updatable_collection]

      resources :users, module: "offices", only: %i[index new create destroy], path: "/utilisateurs" do
        get    :remove,      on: :member
        get    :remove_all,  on: :collection, path: "remove"
        delete :destroy_all, on: :collection, path: "/", as: nil

        concerns :updatable_collection
      end
    end

    resources :users, concerns: %i[removable removable_collection], path: "/utilisateurs"
    resources :users_offices, only: %i[index], controller: "users/offices", path: "/utilisateurs/offices"

    resources :communes,     only: %i[index show edit update]
    resources :epcis,        only: %i[index show edit update]
    resources :departements, only: %i[index show edit update]
    resources :regions,      only: %i[index show edit update]

    resources :organizations, only: %i[index],       path: "/organisations"
    resources :territories,   only: %i[index],       path: "/territoires"
    resource  :territories,   only: %i[edit update], path: "/territoires"
  end

  root to: redirect("/editeurs")
end
