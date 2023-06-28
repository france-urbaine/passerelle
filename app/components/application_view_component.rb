# frozen_string_literal: true

class ApplicationViewComponent < ViewComponent::Base
  class LabelOrContent < self
    def initialize(label = nil)
      @label = label
      super()
    end

    def call
      @label || content
    end
  end

  delegate :current_user, :current_organization, :signed_in?, :allowed_to?, to: :helpers
  delegate :form_block, to: :helpers
end
