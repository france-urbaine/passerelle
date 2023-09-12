# frozen_string_literal: true

module CopyableText
  class Component < ApplicationViewComponent
    def initialize(value, hide: false)
      @value = value
      @hide  = hide
      super()
    end
  end
end
