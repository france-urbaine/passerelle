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
        polymorphic_path(%i[admin dgfip])
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
