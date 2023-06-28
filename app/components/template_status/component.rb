# frozen_string_literal: true

module TemplateStatus
  class Component < ApplicationViewComponent
    renders_one :header, "LabelOrContent"
    renders_one :body, "LabelOrContent"

    renders_many :actions, ::Button::Component
    renders_one :raw_actions

    renders_one :breadcrumbs, ->(**options) { ::Breadcrumbs::Component.new(heading: false, **options) }
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
