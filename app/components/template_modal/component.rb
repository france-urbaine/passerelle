# frozen_string_literal: true

module TemplateModal
  class Component < ApplicationViewComponent
    renders_one :modal, ::Modal::Component

    def initialize(referrer: nil)
      @referrer = referrer
      super()
    end
  end
end
