# frozen_string_literal: true

module ComponentsHelper
  COMPONENT_HELPERS = {
    breadcrumbs_component:    "BreadcrumbsComponent",
    button_component:         "ButtonComponent",
    dialog_component:         "DialogComponent",
    search_component:         "SearchComponent",
    index_options_component:  "IndexOptionsComponent",
    order_column:             "OrderColumnComponent"
  }.freeze

  COMPONENT_HELPERS.each do |name, component|
    define_method name do |*args, **kwargs, &block|
      render component.constantize.new(*args, **kwargs), &block
    end
  end

  # rubocop:disable Rails/HelperInstanceVariable
  #
  def template_frame_component(**options, &)
    raise "Already render template_frame_component" if @template_frame_rendered

    @template_frame_rendered = true
    render TemplateFrameComponent.new(**options), &
  end

  def template_frame_rendered?
    @template_frame_rendered
  end
  #
  # rubocop:enable Rails/HelperInstanceVariable
end
