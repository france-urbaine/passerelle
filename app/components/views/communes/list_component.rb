# frozen_string_literal: true

module Views
  module Communes
    class ListComponent < ApplicationViewComponent
      DEFAULT_COLUMNS = %i[
        name
        departement
        epci
        collectivities_count
      ].freeze

      def initialize(communes, pagy = nil, namespace:, parent: nil)
        @communes  = communes
        @pagy      = pagy
        @namespace = namespace
        @parent    = parent
        super()
      end

      def before_render
        content
        @columns = DEFAULT_COLUMNS if columns.empty?

        @communes = @communes.preload(:departement) if columns.include?(:departement)
        @communes = @communes.preload(:epci)        if columns.include?(:epci)
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

      def allow_action_to?(action, commune)
        case [action, @namespace, @parent]
        in [:destroy?, :admin, Office]
          allowed_to?(:destroy?, commune, with: ::Admin::Offices::CommunePolicy)
        in [:destroy?, :organization, Office]
          allowed_to?(:destroy?, commune, with: ::Organization::Offices::CommunePolicy)
        in [:destroy_all?, :admin, Office]
          allowed_to?(:destroy_all?, Commune, with: ::Admin::Offices::CommunePolicy)
        in [:destroy_all?, :organization, Office]
          allowed_to?(:destroy_all?, Commune, with: ::Organization::Offices::CommunePolicy)
        in [:destroy?, _, _] | [:destroy_all?, _, _]
          false
        else
          allowed_to?(action, commune, with: ::Territories::CommunePolicy)
        end
      end
    end
  end
end
