# frozen_string_literal: true

module UI
  module ContentFlow
    class AbstractBlockComponent < ApplicationViewComponent
      attr_reader :options

      def initialize(**options)
        @options = options
        super()
      end

      def block_type
        @options[:block_type]
      end
    end
  end
end
