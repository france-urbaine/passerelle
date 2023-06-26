# frozen_string_literal: true

module TemplateStatus
  class Component < ApplicationViewComponent
    renders_one :header, "LabelOrContent"
    renders_one :body, "LabelOrContent"

    renders_many :actions, ::Button::Component

    renders_one :breadcrumbs, lambda { |*args, **options|
      if args.first.is_a?(ViewComponent::Slot)
        args.first.to_s
      else
        ::Breadcrumbs::Component.new(heading: false, **options)
      end
    }

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
