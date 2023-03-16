# frozen_string_literal: true

module Datatable
  class ColumnGroupComponent < ViewComponent::Base
    attr_reader :key

    def initialize(key, sort: false)
      @key  = key
      @sort = sort
      super()
    end

    def sort?
      @sort
    end

    def call
      content
    end
  end
end
