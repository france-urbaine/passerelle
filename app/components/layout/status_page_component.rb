# frozen_string_literal: true

module Layout
  class StatusPageComponent < ApplicationViewComponent
    renders_one :header, "LabelOrContent"
    renders_one :body, "LabelOrContent"

    renders_many :actions, UI::ButtonComponent
    renders_one :raw_actions

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
