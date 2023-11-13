# frozen_string_literal: true

module Layout
  module Pagination
    class CountsComponent < ApplicationViewComponent
      define_component_helper :pagination_counts_component

      attr_accessor :pagy, :inflection_options

      def initialize(pagy, ...)
        @pagy = pagy
        @inflection_options = InflectionsOptions.new(...)
        super()
      end
    end
  end
end
