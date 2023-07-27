# frozen_string_literal: true

module DatatableSkeleton
  class Component < ApplicationViewComponent
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
        [@rows, ControllerCollections::NESTED_ITEMS].min
      else
        @rows
      end
    end
  end
end
