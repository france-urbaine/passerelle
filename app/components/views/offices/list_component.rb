# frozen_string_literal: true

module Views
  module Offices
    class ListComponent < ApplicationViewComponent
      DEFAULT_COLUMNS = %i[
        name
        ddfip
        competences
        users_count
        communes_count
        reports_counts
      ].freeze

      def initialize(offices, pagy = nil, namespace:, parent: nil)
        @offices   = offices
        @pagy      = pagy
        @namespace = namespace
        @parent    = parent
        super()
      end

      def before_render
        content
        @columns = DEFAULT_COLUMNS if columns.empty?

        @offices = @offices.preload(:ddfip) if columns.include?(:ddfip)
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

      def allow_action_to?(action, office)
        case [action, @namespace, @parent]
        in [:destroy_all?, :admin, Collectivity]
          false
        else
          allowed_to?(action, office, namespace: @namespace.to_s.classify.constantize)
        end
      end

      def polymorphic_action_path(action, office)
        polymorphic_path([action, @namespace, office])
      end
    end
  end
end
