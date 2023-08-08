# frozen_string_literal: true

module TemplateContent
  class Component < ApplicationViewComponent
    def initialize(src: nil)
      @src = src
      super()
    end
  end
end
