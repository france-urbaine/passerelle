# frozen_string_literal: true

module Views
  module DDFIPs
    class FormComponent < ApplicationViewComponent
      def initialize(ddfip, scope:, redirection_path: nil)
        @ddfip            = ddfip
        @scope            = scope
        @redirection_path = redirection_path
        super()
      end

      def form_url
        url_args = []
        url_args << @scope
        url_args << (@ddfip.new_record? ? :ddfips : @ddfip)

        polymorphic_path(url_args.compact)
      end

      def departement_input_html_attributes
        {
          value:       @ddfip.departement&.qualified_name,
          placeholder: "Commnencez à taper pour sélectionner des départements"
        }
      end
    end
  end
end
