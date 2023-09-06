# frozen_string_literal: true

module Views
  module Users
    class ListComponent < ApplicationViewComponent
      DEFAULT_COLUMNS = %i[
        name
        email
        organization
        organization_admin
        super_admin
        offices
      ].freeze

      def initialize(users, pagy = nil, namespace:, parent: nil)
        @users     = users
        @pagy      = pagy
        @namespace = namespace
        @parent    = parent
        super()
      end

      def before_render
        content
        @columns = DEFAULT_COLUMNS if columns.empty?

        @users = @users.preload(:organization) if columns.include?(:organization)
        @users = @users.preload(:offices)      if columns.include?(:offices)
      end

      def with_column(name)
        columns << name
      end

      def columns
        @columns ||= []
      end

      def nested?
        @parent
      end

      def namespace_module
        @namespace_module ||= @namespace.to_s.classify.constantize
      end

      # Disable these layout cops to allow more comparable lines
      #
      # rubocop:disable Layout/LineLength
      # rubocop:disable Layout/ExtraSpacing
      #
      def allowed_to_edit?(user)
        case [@namespace, @parent]
        in [:organization, Collectivity] then allowed_to?(:edit?, user, with: ::Organization::Collectivities::UserPolicy, context: { collectivity: @parent })
        else                                  allowed_to?(:edit?, user, with: namespace_module::UserPolicy)
        end
      end

      def allowed_to_remove?(user)
        case [@namespace, @parent]
        in [:organization, Collectivity] then allowed_to?(:remove?, user, with: ::Organization::Collectivities::UserPolicy, context: { collectivity: @parent })
        else                                  allowed_to?(:remove?, user, with: namespace_module::UserPolicy)
        end
      end

      def allowed_to_remove_from_office?(user)
        case [@namespace, @parent]
        in [*, Office]                   then allowed_to?(:remove?, user, with: namespace_module::Offices::UserPolicy)
        else false
        end
      end

      def allowed_to_remove_all?
        case [@namespace, @parent]
        in [:organization, Collectivity] then allowed_to?(:destroy_all?, User, with: ::Organization::Collectivities::UserPolicy, context: { collectivity: @parent })
        in [*, Office]                   then allowed_to?(:destroy_all?, User, with: namespace_module::Offices::UserPolicy)
        else                                  allowed_to?(:destroy_all?, User, with: namespace_module::UserPolicy)
        end
      end

      def edit_path(user)
        case [@namespace, @parent]
        in [:organization, Collectivity] then polymorphic_path([:edit, @namespace, @parent, user])
        else                                  polymorphic_path([:edit, @namespace, user])
        end
      end

      def remove_path(user)
        case [@namespace, @parent]
        in [:organization, Collectivity] then polymorphic_path([:remove, @namespace, @parent, user])
        else                                  polymorphic_path([:remove, @namespace, user])
        end
      end
      #
      # rubocop:enable Layout/LineLength
      # rubocop:enable Layout/ExtraSpacing
    end
  end
end
