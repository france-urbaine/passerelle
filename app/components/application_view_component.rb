# frozen_string_literal: true

class ApplicationViewComponent < ViewComponent::Base
  class LabelOrContent < self
    def initialize(label = nil)
      @label = label
      super()
    end

    def call
      @label || content
    end
  end

  delegate :current_user, :current_organization, :signed_in?, :allowed_to?, to: :helpers
  delegate :form_block, to: :helpers

  # Extend renders_one & renders_many to allow a component to forward its slots
  # to another component.
  # Example:
  #
  #   class FooComponent < ApplicationViewComponent
  #     render_one :foo_action, ActionComponent
  #   end
  #
  #   class BarComponent < ApplicationViewComponent
  #     render_one :bar_action, ActionComponent
  #   end
  #
  #   # foo_component.html.slim
  #
  #   = render BarComponent.new do |custom|
  #     - custom.with_bar_action(foo_action)
  #
  # See https://github.com/ViewComponent/view_component/issues/1784
  #
  def self.renders_one(slot_name, callable = nil)
    super(slot_name, override_slot_callabble_to_accept_other_slots(callable))
  end

  def self.renders_many(slot_name, callable = nil)
    super(slot_name, override_slot_callabble_to_accept_other_slots(callable))
  end

  def self.override_slot_callabble_to_accept_other_slots(callable)
    return callable unless callable.is_a?(Class) || callable.is_a?(String)

    lambda { |*args, **options|
      if args.first.is_a?(ViewComponent::Slot)
        args.first.to_s
      elsif callable.is_a?(Class)
        callable.new(*args, **options)
      elsif callable.is_a?(String)
        self.class.const_get(callable).new(*args, **options)
      end
    }
  end

  private_class_method :override_slot_callabble_to_accept_other_slots
end
