# frozen_string_literal: true

module Views
  module Collectivities
    class ListComponent < ApplicationViewComponent
      DEFAULT_COLUMNS = %i[
        name
        siren
        publisher
        contact
        contact_email
        contact_phone
        users_count
        packages_transmitted_count
        reports_transmitted_count
        reports_approved_count
        reports_rejected_count
      ].freeze

      def initialize(collectivities, pagy = nil, namespace:, parent: nil, selectable: true)
        @collectivities = collectivities
        @pagy           = pagy
        @namespace      = namespace
        @parent         = parent
        @selectable     = selectable
        super()
      end

      def before_render
        content
        @columns = DEFAULT_COLUMNS if columns.empty?

        @collectivities = @collectivities.preload(:publisher) if columns.include?(:publisher)
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
        @namespace = :admin if @namespace == :territories
        @namespace&.to_s&.camelize&.safe_constantize
      end

      def link_scope
        @namespace = :admin if @namespace == :territories
        @namespace
      end

      def organization_namespace?
        @namespace == :organization
      end

      def organization_namespace_and_office_parent?
        @namespace == :organization && @parent.is_a?(Office)
      end

      def selectable?
        @selectable
      end
    end
  end
end
