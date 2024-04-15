# frozen_string_literal: true

module UI
  module ModalCall
    class Component < ApplicationViewComponent
      define_component_helper :modal_call_component

      renders_one :button, lambda { |*args, **options, &block|
        options = merge_attributes(
          options,
          data: {
            action: "click->modal-call#open"
          }
        )

        Button::Component.new(*args, **options, &block)
      }

      renders_one :modal, lambda { |**options, &block|
        options[:hidden] = options.fetch(:hidden, true)
        options = merge_attributes(
          options,
          aria: {
            hidden: options[:hidden]
          },
          data: {
            modal_call_target: "modal",
            action:            "modal:close->modal-call#close"
          }
        )

        Modal::Component.new(**options, &block)
      }
    end
  end
end
