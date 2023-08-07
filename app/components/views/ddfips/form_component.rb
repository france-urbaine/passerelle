# frozen_string_literal: true

module Views
  module DDFIPs
    class FormComponent < ApplicationViewComponent
      def initialize(ddfip, scope:, referrer: nil)
        @ddfip    = ddfip
        @scope    = scope
        @referrer = referrer
        super()
      end

      def form_url
        url_args = []
        url_args << @scope
        url_args << (@ddfip.new_record? ? :ddfips : @ddfip)

        polymorphic_path(url_args.compact)
      end

      def redirection_path
        if @referrer.nil? && @ddfip.errors.any? && params[:redirect]
          params[:redirect]
        else
          @referrer
        end
      end

      def departement_input_html_attributes
        {
          value:       @ddfip.departement&.qualified_name,
          placeholder: "Commnencez à taper pour sélectionner un département"
        }
      end
    end
  end
end
