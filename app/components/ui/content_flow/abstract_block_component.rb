# frozen_string_literal: true

module UI
  module ContentFlow
    class AbstractBlockComponent < ApplicationViewComponent
      def initialize(**options)
        @options = options
        super()
      end

      def separator?
        @options[:separator]
      end
    end
  end
end
