# frozen_string_literal: true

module Noscript
  class Component < ApplicationViewComponent
    RequiredInputError = Class.new(StandardError)

    def initialize(id: SecureRandom.alphanumeric)
      @id = id
      super()
    end
  end
end
