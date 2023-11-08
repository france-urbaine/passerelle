# frozen_string_literal: true

module ComponentsHelper
  COMPONENT_HELPERS = {
    # UI generic components
    badge_component:                  "UI::BadgeComponent",
    breadcrumbs_component:            "UI::BreadcrumbsComponent",
    button_component:                 "UI::ButtonComponent",
    card_component:                   "UI::CardComponent",
    code_example_component:           "UI::CodeExampleComponent",
    copyable_component:               "UI::CopyableComponent",
    counter_component:                "UI::CounterComponent",
    description_list_component:       "UI::DescriptionListComponent",
    dropdown_component:               "UI::DropdownComponent",
    icon_component:                   "UI::IconComponent",
    modal_component:                  "UI::ModalComponent",
    noscript_component:               "UI::NoscriptComponent",
    notification_component:           "UI::NotificationComponent",
    tabs_component:                   "UI::TabsComponent",

    # UI form components
    checkboxes_component:             "UI::Form::CheckboxesComponent",
    hidden_field_component:           "UI::Form::HiddenFieldComponent",
    form_block_component:             "UI::Form::BlockComponent",
    radio_buttons_component:          "UI::Form::RadioButtonsComponent",
    password_field_component:         "UI::Form::PasswordFieldComponent",

    # Layout components
    content_frame_component:          "Layout::ContentFrameComponent",
    modal_frame_component:            "Layout::ModalFrameComponent",
    datatable_component:              "Layout::DatatableComponent",
    datatable_skeleton_component:     "Layout::Datatable::SkeletonComponent",
    pagination_component:             "Layout::PaginationComponent",
    pagination_counts_component:      "Layout::Pagination::CountsComponent",
    pagination_options_component:     "Layout::Pagination::OptionsComponent",
    pagination_buttons_component:     "Layout::Pagination::ButtonsComponent",
    search_form_component:            "Layout::SearchFormComponent",
    status_page_component:            "Layout::StatusPageComponent",
    gone_status_page_component:       "Layout::StatusPage::GoneComponent",
    not_found_status_page_component:  "Layout::StatusPage::NotFoundComponent",

    # App-specific helpers as components
    authorized_link_to:               "Helpers::AuthorizedLinkComponent"
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
