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

      # Disable these layout cops to allow more comparable lines
      #
      # rubocop:disable Layout/LineLength
      #
      def allowed_to_show?(commune)
        allowed_to?(:show?, commune, with: ::Territories::CommunePolicy)
      end

      def allowed_to_edit?(commune)
        allowed_to?(:edit?, commune, with: ::Territories::CommunePolicy)
      end

      def allowed_to_remove_from_office?(commune)
        case [@namespace, @parent]
        in [:admin, Office]        then allowed_to?(:destroy?, commune, with: ::Admin::Offices::CommunePolicy)
        in [:organization, Office] then allowed_to?(:destroy?, commune, with: ::Organization::Offices::CommunePolicy)
        else                            false
        end
      end

      def allowed_to_remove_all_from_office?
        case [@namespace, @parent]
        in [:admin, Office]        then allowed_to?(:destroy_all?, Commune, with: ::Admin::Offices::CommunePolicy)
        in [:organization, Office] then allowed_to?(:destroy_all?, Commune, with: ::Organization::Offices::CommunePolicy)
        else                            false
        end
      end

      def allowed_to_show_departement?(departement)
        allowed_to?(:show?, departement, with: ::Territories::DepartementPolicy)
      end

      def allowed_to_show_epci?(epci)
        allowed_to?(:show?, epci, with: ::Territories::EPCIPolicy)
      end
      #
      # rubocop:enable Layout/LineLength
      #
    end
  end
end
