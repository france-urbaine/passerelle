# frozen_string_literal: true

module Views
  module Offices
    class FormComponent < ApplicationViewComponent
      def initialize(office, namespace:, ddfip: nil, referrer: nil)
        @office    = office
        @ddfip     = ddfip
        @namespace = namespace
        @referrer  = referrer
        super()
      end

      def form_url
        url_args = [@namespace]

        if @office.new_record?
          url_args << @ddfip
          url_args << :offices
        else
          url_args << @office
        end

        polymorphic_path(url_args.compact)
      end

      def redirection_path
        if @referrer.nil? && @office.errors.any? && params[:redirect]
          params[:redirect]
        else
          @referrer
        end
      end

      def allowed_to_assign_ddfip?
        @namespace == :admin && @ddfip.nil?
      end

      def ddfip_search_options
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
          [value, I18n.t(value, scope: "enum.competence")]
        end
      end
    end
  end
end
