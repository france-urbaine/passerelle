# frozen_string_literal: true

module Views
  module Users
    class ListComponent < ApplicationViewComponent
      DEFAULT_COLUMNS = %i[
        name
        email
        organization
        roles
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

        @users = @users.preload(:organization)                   if columns.include?(:organization)
        @users = @users.preload(:office_users, :user_form_types) if columns.include?(:roles)
        @users = @users.preload(:offices)                        if columns.intersect?(%i[offices roles])
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

      def allow_action_to?(action, user, from: nil)
        case [action, @namespace, @parent, from]
        in [:remove_all?, :organization, Office, *] | [:remove?, :organization, Office, :office]
          allowed_to?(action, user, namespace: ::Organization::Offices)

        in [:remove_all?, :admin, Office, *] | [:remove?, :admin, Office, :office]
          allowed_to?(action, user, namespace: ::Admin::Offices)

        in [*, :office]
          false

        in [_, :organization, Collectivity, _]
          allowed_to?(action, user, namespace: ::Organization::Collectivities, context: { collectivity: @parent })

        else
          allowed_to?(action, user, namespace: @namespace.to_s.classify.constantize)
        end
      end

      def polymorphic_action_path(action, user)
        case [@namespace, @parent]
        in [:organization, Collectivity]
          polymorphic_path([action, @namespace, @parent, user])
        else
          polymorphic_path([action, @namespace, user])
        end
      end
    end
  end
end
