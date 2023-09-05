# frozen_string_literal: true

module Views
  module Offices
    class ListComponent < ApplicationViewComponent
      DEFAULT_COLUMNS = %i[
        name
        ddfip
        competence
        users_count
        communes_count
        reports_count
        reports_approved_count
        reports_rejected_count
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

      def authorization_namespace
        @namespace.to_s.classify.constantize
      end

      def allowed_to_show?(office)
        allowed_to?(:show?, office)
      end

      def allowed_to_edit?(office)
        allowed_to?(:edit?, office)
      end

      def allowed_to_remove?(office)
        allowed_to?(:remove?, office)
      end

      def allowed_to_remove_all?
        case [@namespace, @parent]
        in [:admin, Collectivity] then false
        else                           allowed_to?(:destroy_all?, Office)
        end
      end

      def allowed_to_show_ddfip?(ddfip)
        case [@namespace, @parent]
        in [:organization, nil] then false
        else                         allowed_to?(:show?, ddfip)
        end
      end
    end
  end
end
