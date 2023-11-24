# frozen_string_literal: true

module Layout
  class StatusPageComponent < ApplicationViewComponent
    define_component_helper :status_page_component

    renders_one :breadcrumbs, "BreadcrumbsSlot"
    renders_one :header, "ContentSlot"
    renders_one :body, "ContentSlot"
    renders_many :actions, "ActionSlot"

    CARD_OPTIONS = {
      content_class: "card__content--status",
      actions_class: "card__actions--center"
    }.freeze

    def initialize(referrer: nil)
      @referrer = referrer
      super()
    end
  end
end
