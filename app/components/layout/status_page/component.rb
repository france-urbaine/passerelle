# frozen_string_literal: true

module Layout
  module StatusPage
    class Component < ApplicationViewComponent
      renders_one :breadcrumbs, "BreadcrumbsSlot"
      renders_one :header, "ContentSlot"
      renders_one :body, "ContentSlot"
      renders_many :actions, "ActionSlot"

      def initialize(referrer: nil)
        @referrer = referrer
        super()
      end
    end
  end
end
