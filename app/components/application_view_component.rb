# frozen_string_literal: true

class ApplicationViewComponent < ViewComponent::Base
  delegate :form_block, to: :helpers

  class LabelOrContent < self
    def initialize(label = nil)
      @label = label
      super()
    end

    def call
      @label || content
    end
  end
end
