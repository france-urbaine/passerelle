# frozen_string_literal: true

module Layout
  class StatusPageComponent < ApplicationViewComponent
    define_component_helper :status_page_component

    renders_one :header, "ContentSlot"
    renders_one :body, "ContentSlot"
    renders_many :actions, "ActionSlot"

    renders_one :breadcrumbs, ->(**options) { UI::BreadcrumbsComponent.new(heading: false, **options) }
    renders_one :raw_breadcrumbs

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
