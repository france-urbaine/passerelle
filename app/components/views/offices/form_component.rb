# frozen_string_literal: true

module Views
  module Offices
    class FormComponent < ApplicationViewComponent
      def initialize(office, scope:, ddfip: nil, redirection_path: nil)
        @office           = office
        @ddfip            = ddfip
        @scope            = scope
        @redirection_path = redirection_path
        super()
      end

      def form_url
        url_args = [@scope]

        if @office.new_record?
          url_args << @ddfip
          url_args << :offices
        else
          url_args << @office
        end

        polymorphic_path(url_args.compact)
      end

      def allowed_to_assign_ddfip?
        @scope == :admin && @ddfip.nil?
      end

      def ddfip_input_html_attributes
        {
          value:       ddfip_name,
          placeholder: "Commnencez à taper pour sélectionner une DDFIP"
        }
      end

      def ddfip_name
        @office.ddfip&.name
      end

      def competences_choice
        Office::COMPETENCES.map do |value|
          [
            I18n.t(value, scope: "enum.competence"),
            value
          ]
        end
      end
    end
  end
end
