# frozen_string_literal: true

module TemplateStatus
  module NotFound
    class Component < ApplicationViewComponent
      renders_one :header, "LabelOrContent"
      renders_one :body, "LabelOrContent"
      renders_many :actions, ::Button::Component
      renders_one :breadcrumbs, ->(**options) { ::Breadcrumbs::Component.new(heading: false, **options) }

      def initialize(model, **options)
        @model = model
        @options = options
        super()
      end
    end
  end
end
