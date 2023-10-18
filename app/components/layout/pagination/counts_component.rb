# frozen_string_literal: true

module Layout
  module Pagination
    class CountsComponent < ApplicationViewComponent
      attr_accessor :pagy, :inflection_options

      def initialize(pagy, ...)
        @pagy = pagy
        @inflection_options = InflectionsOptions.new(...)
        super()
      end
    end
  end
end
