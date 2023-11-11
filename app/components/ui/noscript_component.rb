# frozen_string_literal: true

module UI
  class NoscriptComponent < ApplicationViewComponent
    define_component_helper :noscript_component

    def initialize(id: SecureRandom.alphanumeric)
      @id = id
      super()
    end
  end
end
