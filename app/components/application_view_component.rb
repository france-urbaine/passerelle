# frozen_string_literal: true

class ApplicationViewComponent < ViewComponent::Base
  module Helpers; end

  include Helpers
  include ActionPolicy::Behaviour

  class ContentSlot < self
    def initialize(label = nil)
      @label = label
      super()
    end

    def call
      if @label
        html_escape(@label)
      else
        content
      end
    end
  end

  class ActionSlot < self
    def initialize(*args, **options)
      @args = args
      @options = options
      super()
    end

    def call
      if @args.any? || @options.any?
        render UI::Button::Component.new(*@args, **@options)
      else
        content
      end
    end
  end

  class BreadcrumbsSlot < self
    def initialize(**options)
      @options = options
      super()
    end

    delegate_missing_to :original_breadcrumbs

    def original_breadcrumbs
      @original_breadcrumbs ||= ::UI::Breadcrumbs::Component.new(**@options)
    end

    def call
      content

      if original_breadcrumbs.h1? || original_breadcrumbs.paths? || original_breadcrumbs.actions?
        render original_breadcrumbs
      else
        content
      end
    end
  end

  # Delegate devise methods
  delegate :current_user, :signed_in?, to: :helpers

  # Setup policies context
  authorize :user, through: :current_user

  def turbo_frame_request_id
    request.headers["Turbo-Frame"]
  end

  def turbo_frame_request?
    turbo_frame_request_id.present?
  end

  def current_organization
    current_user&.organization
  end

  def self.define_component_helper(method_name)
    component_class_name = name

    helper_module = Module.new do
      define_method method_name do |*args, **kwargs, &block|
        render component_class_name.constantize.new(*args, **kwargs), &block
      end
    end

    Helpers.prepend helper_module
  end

  private_class_method :define_component_helper
end

# Eager load components to get all helpers methods available
Rails.autoloaders.main.eager_load_dir(__dir__)
