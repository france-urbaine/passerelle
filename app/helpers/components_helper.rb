# frozen_string_literal: true

module ComponentsHelper
  COMPONENT_HELPERS = {
    breadcrumbs_component:        "Breadcrumbs::Component",
    button_component:             "Button::Component",
    checkboxes_component:         "Checkboxes::Component",
    card_component:               "Card::Component",
    datatable_component:          "DataTable::Component",
    datatable_skeleton_component: "DataTable::Skeleton::Component",
    dropdown_component:           "Dropdown::Component",
    modal_component:              "Modal::Component",
    notification_component:       "Notification::Component",
    pagination_component:         "Pagination::Component",
    pagination_counts_component:  "Pagination::Counts::Component",
    pagination_options_component: "Pagination::Options::Component",
    pagination_buttons_component: "Pagination::Buttons::Component",
    search_component:             "Search::Component"
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
    render TemplateFrame::Component.new(**options), &
  end

  def template_frame_rendered?
    @template_frame_rendered
  end
  #
  # rubocop:enable Rails/HelperInstanceVariable
end
