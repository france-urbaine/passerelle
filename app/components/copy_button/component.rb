# frozen_string_literal: true

module CopyButton
  class Component < ApplicationViewComponent
    def initialize(value)
      @value = value
      super()
    end
  end
end
