# frozen_string_literal: true

module Layout
  module StatusPage
    class NotFoundComponent < ApplicationViewComponent
      define_component_helper :not_found_status_page_component

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
