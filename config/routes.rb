# frozen_string_literal: true

require "sidekiq/web"

Rails.application.routes.draw do
  # Concerns
  # ----------------------------------------------------------------------------
  concern :removable do |options|
    get   :remove,    on: :member
    patch :undiscard, on: :member unless options[:undiscard] == false
  end

  concern :removable_collection do |options|
    get    :remove_all,    on: :collection, path: "remove"
    delete :destroy_all,   on: :collection, path: "/", as: nil
    patch  :undiscard_all, on: :collection, path: "undiscard" unless options[:undiscard] == false
  end

  concern :updatable_collection do
    get   :edit_all,   on: :collection, path: "edit"
    patch :update_all, on: :collection, path: "/", as: nil
  end

  # User stuff
  # ----------------------------------------------------------------------------
  devise_for :users, path: "/", controllers: {
    sessions:      "users/sessions",
    confirmations: "users/confirmations",
    passwords:     "users/passwords",
    unlocks:       "users/unlocks"
  }, path_names: {
    sign_in:    "connexion"
  }

  namespace :users, as: :user, path: "/" do
    resource :enrollment,              path: "/inscription",                    only: %i[new], path_names: { new: "/" }
    resource :registration,            path: "/enregistrement/:token",          only: %i[show]
    resource :registration_password,   path: "/enregistrement/:token/password", only: %i[new create]
    resource :registration_two_factor, path: "/enregistrement/:token/2fa",      only: %i[new create edit update]

    resource :user_settings,           path: "/compte/parametres",   only: %i[show update], as: :settings
    resource :two_factor_settings,     path: "/compte/2fa",          only: %i[new create edit update]

    get "/compte", to: redirect("/compte/parametres")
  end

  unauthenticated do
    root to: redirect("/connexion")
  end

  authenticated :user do
    root "dashboards#index", as: :authenticated_root
  end

  authenticate :user, ->(user) { user.super_admin? } do
    mount Sidekiq::Web => "/sidekiq"
  end

  # Test passwords strength
  # ----------------------------------------------------------------------------
  get "/password/strength_test", to: "passwords#strength_test"

  # Combined autocompletions
  # ----------------------------------------------------------------------------
  resources :organizations, only: %i[index], path: "/organisations"
  resources :territories,   only: %i[index], path: "/territoires"

  # Shared stuff
  # ----------------------------------------------------------------------------
  resources :dashboards, only: %i[index], path: "/"

  constraints(id: %r{(?!(new|edit|remove|discard|undiscard|guichets))[^/]+}) do
    # Reports stuff
    # ----------------------------------------------------------------------------
    resources :reports, path: "signalements", concerns: %i[removable removable_collection], path_names: { edit: "/edit/:form" } do
      scope module: "reports" do
        resources :attachments, only: %i[new create destroy]
        resource  :approval,    only: %i[show update destroy]
      end
    end

    resources :packages, only: %i[index show edit update destroy], concerns: %i[removable removable_collection], path: "paquets" do
      scope module: "packages" do
        resource  :transmission, only: %i[show update]
        resource  :approval,     only: %i[show update destroy]
        resources :reports,      only: %i[index], concerns: %i[removable_collection], path: "signalements"
      end
    end

    # Organization stuff
    # ----------------------------------------------------------------------------
    namespace :organization, path: "/organisation" do
      resource  :settings, only: %i[show update], path: "/parametres"

      resources :collectivities, concerns: %i[removable removable_collection], path: "/collectivites" do
        scope module: "collectivities" do
          resources :offices, only: %i[index], path: "/guichets"
          resources :users,   concerns: %i[removable removable_collection], path: "/utilisateurs"
        end
      end

      resources :offices, concerns: %i[removable removable_collection], path: "/guichets" do
        scope module: "offices" do
          resources :users, only: %i[index new create destroy], path: "/utilisateurs" do
            concerns :removable,            undiscard: false
            concerns :removable_collection, undiscard: false
            concerns :updatable_collection
          end

          resources :communes, only: %i[index destroy] do
            concerns :removable,            undiscard: false
            concerns :removable_collection, undiscard: false
            concerns :updatable_collection
          end

          resources :collectivities, only: %i[index], path: "/collectivites"
        end
      end

      resources :users, concerns: %i[removable removable_collection], path: "/utilisateurs"
    end

    # Admin stuff
    # ----------------------------------------------------------------------------
    namespace :admin do
      resources :publishers, concerns: %i[removable removable_collection], path: "/editeurs" do
        scope module: "publishers" do
          resources :collectivities, only: %i[index new create], concerns: %i[removable_collection], path: "/collectivites"
          resources :users,          only: %i[index new create], concerns: %i[removable_collection], path: "/utilisateurs"
        end
      end

      resources :collectivities, concerns: %i[removable removable_collection], path: "/collectivites" do
        scope module: "collectivities" do
          resources :offices, only: %i[index], path: "/guichets"
          resources :users,   only: %i[index new create], concerns: %i[removable_collection], path: "/utilisateurs"
        end
      end

      resource :dgfip, only: %i[show edit update] do
        scope module: "dgfips" do
          resources :users, only: %i[index new create], concerns: %i[removable_collection], path: "/utilisateurs"
        end
      end

      resources :ddfips, concerns: %i[removable removable_collection] do
        scope module: "ddfips" do
          resources :offices,        only: %i[index new create], concerns: %i[removable_collection], path: "/guichets"
          resources :users,          only: %i[index new create], concerns: %i[removable_collection], path: "/utilisateurs"
          resources :collectivities, only: %i[index], path: "/collectivites"
        end
      end

      resources :offices, concerns: %i[removable removable_collection], path: "/guichets" do
        scope module: "offices" do
          resources :users, only: %i[index new create destroy], path: "/utilisateurs" do
            concerns :removable,            undiscard: false
            concerns :removable_collection, undiscard: false
            concerns :updatable_collection
          end

          resources :communes, only: %i[index destroy] do
            concerns :removable,            undiscard: false
            concerns :removable_collection, undiscard: false
            concerns :updatable_collection
          end

          resources :collectivities, only: %i[index], path: "/collectivites"
        end
      end

      resources :users, concerns: %i[removable removable_collection], path: "/utilisateurs"
      resources :users_offices, only: %i[index], controller: "users/offices", path: "/utilisateurs/guichets"
    end

    # Territories stuff
    # ----------------------------------------------------------------------------
    namespace :territories, path: "/territoires" do
      resources :communes, only: %i[index show edit update] do
        scope module: "communes" do
          resources :collectivities, only: %i[index], path: "/collectivites"
        end
      end

      resources :epcis, only: %i[index show edit update] do
        scope module: "epcis" do
          resources :communes,       only: %i[index]
          resources :collectivities, only: %i[index], path: "/collectivites"
        end
      end

      resources :departements, only: %i[index show edit update] do
        scope module: "departements" do
          resources :communes,       only: %i[index]
          resources :epcis,          only: %i[index]
          resources :collectivities, only: %i[index], path: "/collectivites"
        end
      end

      resources :regions, only: %i[index show edit update] do
        scope module: "regions" do
          resources :departements,   only: %i[index]
          resources :ddfips,         only: %i[index]
          resources :collectivities, only: %i[index], path: "/collectivites"
        end
      end

      resource :update, only: %i[edit update], path: "/mise-a-jour", path_names: { edit: "/" }
    end
  end

  # Errors pages
  # ----------------------------------------------------------------------------
  get "404", to: "exceptions#not_found"
  get "406", to: "exceptions#not_acceptable"
  get "422", to: "exceptions#unprocessable_entity"
  get "500", to: "exceptions#internal_server_error"

  # Development extensiosn
  # ----------------------------------------------------------------------------
  mount Lookbook::Engine, at: "/lookbook" if Rails.env.development?

  get "/test/components", to: "exceptions#testing" if Rails.env.test?
end
