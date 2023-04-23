# frozen_string_literal: true

class PageCountComponent < ViewComponent::Base
  renders_one :inflections, ::InflectionsComponent

  attr_accessor :pagy

  def initialize(pagy, *args, **kwargs)
    @pagy = pagy
    super()
    with_inflections(*args, **kwargs) if args.any? || kwargs.any?
  end
end
