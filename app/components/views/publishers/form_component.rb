# frozen_string_literal: true

module Views
  module Publishers
    class FormComponent < ApplicationViewComponent
      def initialize(publisher, namespace:, referrer: nil)
        @publisher = publisher
        @namespace = namespace
        @referrer  = referrer
        super()
      end

      def form_url
        url_args = []
        url_args << @namespace
        url_args << (@publisher.new_record? ? :publishers : @publisher)

        polymorphic_path(url_args.compact)
      end

      def redirection_path
        if @referrer.nil? && @publisher.errors.any? && params[:redirect]
          params[:redirect]
        else
          @referrer
        end
      end
    end
  end
end
