# frozen_string_literal: true

module Layout
  module Datatable
    class SkeletonComponent < ApplicationViewComponent
      define_component_helper :datatable_skeleton_component

      renders_one :search
      renders_one :pagination

      attr_reader :columns

      def initialize(rows: 5, columns: 3, nested: true)
        @rows    = rows
        @columns = Array.new(columns)
        @nested  = nested

        super()
      end

      def rows
        if @nested
          [@rows, ControllerCollections::NESTED_PAGE_LIMIT].min
        else
          @rows
        end
      end
    end
  end
end
