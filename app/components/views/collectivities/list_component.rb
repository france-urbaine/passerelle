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

      def allow_action_to?(action, collectivity)
        case [action, @namespace, @parent]
        in [:destroy_all?, :admin, DDFIP] | [:destroy_all?, _, Office] | [:destroy_all?, :territories, _]
          false
        in [_, :territories, _]
          allowed_to?(action, collectivity, namespace: Admin)
        else
          allowed_to?(action, collectivity, namespace: @namespace.to_s.classify.constantize)
        end
      end

      def polymorphic_action_path(action, collectivity)
        case @namespace
        when :territories then polymorphic_path([action, :admin, collectivity])
        else polymorphic_path([action, @namespace, collectivity])
        end
      end
    end
  end
end
