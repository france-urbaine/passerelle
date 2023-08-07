# frozen_string_literal: true

module Pagination
  class Component < ApplicationViewComponent
    attr_reader :pagy, :turbo_frame, :direction, :order, :inflections_options

    def initialize(pagy, *, turbo_frame: "_top", direction: "left", options: true, order: {}, **)
      @pagy                = pagy
      @turbo_frame         = turbo_frame
      @direction           = direction
      @options             = options
      @order               = order
      @inflections_options = ::InflectionsOptions.new(*, **)
      super()
    end

    def options?
      @options
    end
  end
end
