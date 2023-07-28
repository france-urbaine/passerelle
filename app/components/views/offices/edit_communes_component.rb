# frozen_string_literal: true

module Views
  module Offices
    class EditCommunesComponent < ApplicationViewComponent
      def initialize(office, scope:, redirection_path: nil)
        @office           = office
        @scope            = scope
        @redirection_path = redirection_path
        super()
      end

      def form_url
        polymorphic_path([@scope, @office, :communes].compact)
      end

      def suggested_epcis
        EPCI.having_communes(suggested_communes).order(:name)
      end

      def suggested_communes
        @office.departement_communes.order(:code_insee)
      end
    end
  end
end
