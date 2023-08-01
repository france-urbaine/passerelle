# frozen_string_literal: true

module ComponentsHelper
  COMPONENT_HELPERS = {
    breadcrumbs_component:        "Breadcrumbs::Component",
    button_component:             "Button::Component",
    checkboxes_component:         "Checkboxes::Component",
    card_component:               "Card::Component",
    datatable_component:          "Datatable::Component",
    datatable_skeleton_component: "DatatableSkeleton::Component",
    dropdown_component:           "Dropdown::Component",
    hidden_field_component:       "HiddenField::Component",
    form_block_component:         "FormBlock::Component",
    modal_component:              "Modal::Component",
    noscript_component:           "Noscript::Component",
    notification_component:       "Notification::Component",
    pagination_component:         "Pagination::Component",
    pagination_counts_component:  "Pagination::Counts::Component",
    pagination_options_component: "Pagination::Options::Component",
    pagination_buttons_component: "Pagination::Buttons::Component",
    radio_buttons_component:      "RadioButtons::Component",
    search_component:             "Search::Component"
  }.freeze

  COMPONENT_HELPERS.each do |name, component|
    define_method name do |*args, **kwargs, &block|
      render component.constantize.new(*args, **kwargs), &block
    end
  end

  TEMPLATE_COMPONENT_HELPERS = {
    template_frame_component:     "TemplateFrame::Component",
    template_status_component:    "TemplateStatus::Component",
    template_gone_component:      "TemplateStatus::Gone::Component",
    template_not_found_component: "TemplateStatus::NotFound::Component"
  }.freeze

  # rubocop:disable Rails/HelperInstanceVariable
  #
  TEMPLATE_COMPONENT_HELPERS.each do |name, component|
    define_method name do |*args, **kwargs, &block|
      raise "Already render template_frame_component" if @template_frame_rendered

      @template_frame_rendered = true
      render component.constantize.new(*args, **kwargs), &block
    end
  end

  def template_frame_rendered?
    @template_frame_rendered
  end
  #
  # rubocop:enable Rails/HelperInstanceVariable
end
