# frozen_string_literal: true

Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

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

  mount Lookbook::Engine, at: "/lookbook" if Rails.env.development?

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
    root to: redirect("/signalements"), as: :authenticated_root
  end

  constraints(id: %r{(?!(new|edit|remove|discard|undiscard|offices))[^/]+}) do
    resources :reports, path: "signalements", concerns: %i[removable removable_collection], path_names: { edit: "/edit/:form" } do
      scope module: "reports" do
        resources :attachments, only: %i[new create destroy]
      end
    end

    resources :packages, only: %i[index show edit update destroy], concerns: %i[removable removable_collection], path: "paquets" do
      scope module: "packages" do
        resource  :transmission, only: %i[show update]
        resource  :approval,     only: %i[show update destroy]
        resources :reports,      only: %i[index], concerns: %i[removable_collection], path: "signalements"
      end
    end

    resources :publishers, only: [], path: "/editeurs" do
      scope module: "publishers" do
        resources :users,          only: %i[index new create], concerns: %i[removable_collection], path: "/utilisateurs"
      end
    end

    resources :collectivities, only: [], path: "/collectivites" do
      scope module: "collectivities" do
        resources :users,    only: %i[index new create], concerns: %i[removable_collection], path: "/utilisateurs"
      end
    end

    resources :ddfips, only: [] do
      scope module: "ddfips" do
        resources :users,          only: %i[index new create], concerns: %i[removable_collection], path: "/utilisateurs"
      end
    end

    resources :offices, only: [], path: "/guichets" do
      scope module: "offices" do
        resources :communes, only: %i[index destroy] do
          get    :remove,      on: :member
          get    :remove_all,  on: :collection, path: "remove"
          delete :destroy_all, on: :collection, path: "/", as: nil

          concerns :updatable_collection
        end

        resources :users, only: %i[index new create destroy], path: "/utilisateurs" do
          get    :remove,      on: :member
          get    :remove_all,  on: :collection, path: "remove"
          delete :destroy_all, on: :collection, path: "/", as: nil

          concerns :updatable_collection
        end
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

    # Organization stuff
    # ----------------------------------------------------------------------------
    namespace :organization, path: "/organisation" do
      resource  :settings,       only: %i[show update], path: "/parametres"
      resources :collectivities, concerns: %i[removable removable_collection], path: "/collectivites"
      resources :offices,        concerns: %i[removable removable_collection], path: "/guichets"
    end

    # Admin stuff
    # ----------------------------------------------------------------------------
    namespace :admin do
      resources :publishers, concerns: %i[removable removable_collection], path: "/editeurs" do
        scope module: "publishers" do
          resources :collectivities, only: %i[index new create], concerns: %i[removable_collection], path: "/collectivites"
        end
      end

      resources :collectivities, concerns: %i[removable removable_collection], path: "/collectivites" do
        scope module: "collectivities" do
          resources :offices, only: %i[index], path: "/guichets"
        end
      end

      resources :ddfips, concerns: %i[removable removable_collection] do
        scope module: "ddfips" do
          resources :offices,        only: %i[index new create], concerns: %i[removable_collection], path: "/guichets"
          resources :collectivities, only: %i[index], path: "/collectivites"
        end
      end

      resources :offices, concerns: %i[removable removable_collection], path: "/guichets" do
        scope module: "offices" do
          resources :collectivities, only: %i[index], path: "/collectivites"
        end
      end
    end
  end
end
