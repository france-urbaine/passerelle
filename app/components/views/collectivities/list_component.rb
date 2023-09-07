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

      def initialize(collectivities, pagy = nil, namespace:, parent: nil)
        @collectivities = collectivities
        @pagy           = pagy
        @namespace      = namespace
        @parent         = parent
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
        case @namespace
        when :territories then Admin
        else @namespace.to_s.classify.constantize
        end
      end

      def link_scope
        case @namespace
        when :territories then :admin
        else @namespace
        end
      end
    end
  end
end
