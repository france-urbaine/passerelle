# frozen_string_literal: true

module Card
  class Component < ApplicationViewComponent
    renders_one :header, "LabelOrContent"
    renders_one :body, "LabelOrContent"
    renders_many :actions, "Action"

    def initialize(**options)
      @options = options
      super()
    end

    def css_classes(key)
      { class: Array.wrap(@options.fetch(key, [])) }
    end

    class Action < ::Button::Component
    end
  end
end
