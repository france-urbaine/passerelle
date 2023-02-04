# frozen_string_literal: true

module ComponentsHelper
  # standard:disable Layout/HashAlignment
  COMPONENT_HELPERS = {
    dialog_component:         "DialogComponent",
    search_component:         "SearchComponent",
    index_options_component:  "IndexOptionsComponent",
    order_column:             "OrderColumnComponent"
  }.freeze
  # standard:enable Layout/HashAlignment

  COMPONENT_HELPERS.each do |name, component|
    define_method name do |*args, **kwargs, &block|
      render component.constantize.new(*args, **kwargs), &block
    end
  end
end
