# frozen_string_literal: true

module Layout
  module StatusPage
    module NotFound
      class Component < ApplicationViewComponent
        define_component_helper :not_found_status_page_component

        renders_one :breadcrumbs, "BreadcrumbsSlot"
        renders_one :header, "ContentSlot"
        renders_one :body, "ContentSlot"
        renders_many :actions, "ActionSlot"

        def initialize(model, **options)
          @model = model
          @options = options
          super()
        end
      end
    end
  end
end
