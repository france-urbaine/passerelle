# frozen_string_literal: true

module ComponentsHelper
  COMPONENT_HELPERS = {
    authorized_link_to:               "AuthorizedLink::Component",
    badge_component:                  "Badge::Component",
    breadcrumbs_component:            "Breadcrumbs::Component",
    button_component:                 "Button::Component",
    checkboxes_component:             "Checkboxes::Component",
    card_component:                   "Card::Component",
    counter_badge_component:          "CounterBadge::Component",
    datatable_component:              "Datatable::Component",
    datatable_skeleton_component:     "DatatableSkeleton::Component",
    documentation_examples_component: "DocumentationExamples::Component",
    dropdown_component:               "Dropdown::Component",
    hidden_field_component:           "HiddenField::Component",
    form_block_component:             "FormBlock::Component",
    icon_component:                   "Icon::Component",
    modal_component:                  "Modal::Component",
    noscript_component:               "Noscript::Component",
    notification_component:           "Notification::Component",
    pagination_component:             "Pagination::Component",
    pagination_counts_component:      "Pagination::Counts::Component",
    pagination_options_component:     "Pagination::Options::Component",
    pagination_buttons_component:     "Pagination::Buttons::Component",
    password_field_component:         "PasswordField::Component",
    copyable_text_component:          "CopyableText::Component",
    priority_icon_component:          "PriorityIcon::Component",
    radio_buttons_component:          "RadioButtons::Component",
    search_component:                 "Search::Component",
    tabs_component:                   "Tabs::Component",
    template_content_component:       "TemplateContent::Component",
    template_modal_component:         "TemplateModal::Component",
    template_status_component:        "TemplateStatus::Component",
    template_gone_component:          "TemplateStatus::Gone::Component",
    template_not_found_component:     "TemplateStatus::NotFound::Component"
  }.freeze

  COMPONENT_HELPERS.each do |name, component|
    define_method name do |*args, **kwargs, &block|
      render component.constantize.new(*args, **kwargs), &block
    end
  end

  def report_badge(...)
    render Views::Reports::StatusBadgeComponent.new(...)
  end

  def package_badge(...)
    render Views::Packages::StatusBadgeComponent.new(...)
  end

  def priority_badge(...)
    render Views::Reports::PriorityBadgeComponent.new(...)
  end
end
