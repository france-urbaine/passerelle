# frozen_string_literal: true

module TemplateFrame
  class Component < ApplicationViewComponent
    renders_one :modal_frame
    renders_one :modal_component, ::Modal::Component

    def initialize(src: nil)
      @content_src = src
      super()
    end

    def with_modal(src: nil, redirection_path: @content_src, &block)
      @modal_src = src

      if block&.arity&.positive?
        with_modal_component(redirection_path: redirection_path, &block)
      else
        with_modal_frame(&block)
      end
    end

    def modal
      if modal_frame?
        modal_frame
      else
        modal_component
      end
    end

    def turbo_frame_request?
      turbo_frame_request_id.present?
    end

    def turbo_frame_request_id
      request.headers["Turbo-Frame"]
    end
  end
end
