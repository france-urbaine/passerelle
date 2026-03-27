# frozen_string_literal: true

module Layout
  module StatusPage
    module NotFound
      class Component < ApplicationViewComponent
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
