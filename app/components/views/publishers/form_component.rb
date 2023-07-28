# frozen_string_literal: true

module Views
  module Publishers
    class FormComponent < ApplicationViewComponent
      def initialize(publisher, scope:, redirection_path: nil)
        @publisher        = publisher
        @scope            = scope
        @redirection_path = redirection_path
        super()
      end

      def form_url
        url_args = []
        url_args << @scope
        url_args << (@publisher.new_record? ? :publishers : @publisher)

        polymorphic_path(url_args.compact)
      end
    end
  end
end
