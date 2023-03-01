# frozen_string_literal: true

class TemplateFrameComponent < ViewComponent::Base
  renders_one :modal

  def initialize(src: nil)
    @content_src = src
    super()
  end

  def with_modal(src: nil, &)
    @modal_src = src
    set_slot(:modal, &)
  end

  def turbo_frame_request?
    helpers.request.headers["Turbo-Frame"].present?
  end
end
