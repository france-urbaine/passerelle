# frozen_string_literal: true

module Views
  module Collectivities
    class FormComponent < ApplicationViewComponent
      def initialize(collectivity, scope:, publisher: nil, referrer: nil)
        @collectivity = collectivity
        @publisher    = publisher
        @scope        = scope
        @referrer     = referrer
        super()
      end

      def form_url
        url_args = [@scope]

        if @collectivity.new_record?
          url_args << @publisher
          url_args << :collectivities
        else
          url_args << @collectivity
        end

        polymorphic_path(url_args.compact)
      end

      def redirection_path
        if @referrer.nil? && @collectivity.errors.any? && params[:redirect]
          params[:redirect]
        else
          @referrer
        end
      end

      def allowed_to_assign_publisher?
        @scope == :admin && @publisher.nil?
      end

      def allowed_to_allow_publisher_management?
        @scope == :admin
      end

      def publisher_id_choice
        Publisher.pluck(:name, :id)
      end

      def publisher_id_options
        {}.tap do |options|
          options[:include_blank] = "Aucun éditeur ou éditeur absent de la liste"
          options[:prompt] = "Sélectionnez un éditeur" if @collectivity.new_record? && @collectivity.errors.empty?
        end
      end

      def territory_input_html_attributes
        {
          value:       @collectivity.territory&.qualified_name,
          placeholder: "Commnencez à taper pour sélectionner un territoire"
        }
      end

      def territory_hidden_html_attributes
        return {} unless @collectivity.territory

        {
          value: {
            type: @collectivity.territory_type,
            id:   @collectivity.territory_id
          }.to_json
        }
      end

      def territory_type_choice
        [
          Commune,
          EPCI,
          Departement,
          Region
        ].map { |m| [m.model_name.human, m.name] }
      end

      def territory_code
        case @collectivity.territory
        when Commune     then @collectivity.territory.code_insee
        when EPCI        then @collectivity.territory.siren
        when Departement then @collectivity.territory.code_departement
        when Region      then @collectivity.territory.code_region
        end
      end
    end
  end
end
