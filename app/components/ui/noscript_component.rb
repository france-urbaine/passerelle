# frozen_string_literal: true

module UI
  class NoscriptComponent < ApplicationViewComponent
    def initialize(id: SecureRandom.alphanumeric)
      @id = id
      super()
    end
  end
end
