# frozen_string_literal: true

module DataTable
  module Skeleton
    class Component < ApplicationViewComponent
      renders_one :search
      renders_one :pagination

      attr_reader :rows, :columns

      def initialize(rows: 5, columns: 3)
        @rows    = rows
        @columns = Array.new(columns)
        super()
      end
    end
  end
end
