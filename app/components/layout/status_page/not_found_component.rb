# frozen_string_literal: true

module Layout
  module StatusPage
    class NotFoundComponent < ApplicationViewComponent
      renders_one :header, "LabelOrContent"
      renders_one :body, "LabelOrContent"

      renders_many :actions, UI::ButtonComponent

      renders_one :breadcrumbs, ->(**options) { UI::BreadcrumbsComponent.new(heading: false, **options) }

      def initialize(model, **options)
        @model = model
        @options = options
        super()
      end
    end
  end
end
