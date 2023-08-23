# frozen_string_literal: true

module Views
  module DGFIPs
    class FormComponent < ApplicationViewComponent
      def initialize(dgfip, namespace:, referrer: nil)
        @dgfip     = dgfip
        @namespace = namespace
        @referrer  = referrer
        super()
      end

      def form_url
        url_args = []
        url_args << @namespace
        url_args << (@dgfip.new_record? ? :dgfips : @dgfip)

        polymorphic_path(url_args.compact)
      end

      def redirection_path
        if @referrer.nil? && @dgfip.errors.any? && params[:redirect]
          params[:redirect]
        else
          @referrer
        end
      end
    end
  end
end
