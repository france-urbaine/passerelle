# frozen_string_literal: true

module Views
  module DDFIPs
    class FormComponent < ApplicationViewComponent
      def initialize(ddfip, namespace:, referrer: nil)
        @ddfip     = ddfip
        @namespace = namespace
        @referrer  = referrer
        super()
      end

      def form_url
        url_args = []
        url_args << @namespace
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

      def departement_search_options
        {
          value:       @ddfip.departement&.qualified_name,
          placeholder: "Commnencez à taper pour sélectionner un département"
        }
      end
    end
  end
end
