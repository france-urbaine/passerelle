# frozen_string_literal: true

module ComponentsHelper
  # standard:disable Layout/HashAlignment

  LAYOUT_COMPONENT_HELPERS = {
    layout_main_frame_component:  "Layout::MainFrameComponent",
    layout_modal_frame_component: "Layout::ModalFrameComponent",
    layout_header_component:      "Layout::HeaderComponent"
  }.freeze

  COMPONENT_HELPERS = {
    dialog_component:         "DialogComponent",
    search_component:         "SearchComponent",
    index_options_component:  "IndexOptionsComponent",
    order_column:             "OrderColumnComponent"
  }.freeze

  # standard:enable Layout/HashAlignment

  LAYOUT_COMPONENT_HELPERS.each do |name, component|
    define_method "#{name}_rendered?" do
      instance_variable_get(:"@#{name}_rendered")
    end

    define_method name do |*args, **kwargs, &block|
      return if instance_variable_get(:"@#{name}_rendered")

      instance_variable_set(:"@#{name}_rendered", true)

      render component.constantize.new(*args, **kwargs), &block
    end
  end

  COMPONENT_HELPERS.each do |name, component|
    define_method name do |*args, **kwargs, &block|
      render component.constantize.new(*args, **kwargs), &block
    end
  end
end
