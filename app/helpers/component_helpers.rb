# frozen_string_literal: true

module ComponentHelpers
  # Please order helpers by class name alphabetical order
  #
  {
    authorized_link_to:              "Helpers::AuthorizedLinkComponent",
    datatable_component:             "Layout::DatatableComponent",
    content_frame_component:         "Layout::ContentFrame::Component",
    content_layout_component:        "Layout::ContentLayout::Component",
    datatable_skeleton_component:    "Layout::Datatable::SkeletonComponent",
    modal_frame_component:           "Layout::ModalFrame::Component",
    pagination_component:            "Layout::Pagination::Component",
    pagination_buttons_component:    "Layout::Pagination::Buttons::Component",
    pagination_counts_component:     "Layout::Pagination::Counts::Component",
    pagination_options_component:    "Layout::Pagination::Options::Component",
    status_page_component:           "Layout::StatusPage::Component",
    forbidden_status_page_component: "Layout::StatusPage::Forbidden::Component",
    gone_status_page_component:      "Layout::StatusPage::Gone::Component",
    not_found_status_page_component: "Layout::StatusPage::NotFound::Component",
    badge_component:                 "UI::Badge::Component",
    breadcrumbs_component:           "UI::Breadcrumbs::Component",
    button_component:                "UI::Button::Component",
    card_component:                  "UI::Card::Component",
    chart_number_component:          "UI::Charts::Number::Component",
    code_example_component:          "UI::CodeExample::Component",
    code_request_example_component:  "UI::CodeRequestExample::Component",
    copyable_component:              "UI::Copyable::Component",
    counter_component:               "UI::Counter::Component",
    datalist_component:              "UI::Datalist::Component",
    description_list_component:      "UI::DescriptionList::Component",
    dropdown_component:              "UI::Dropdown::Component",
    flash_component:                 "UI::Flash::Component",
    array_field_component:           "UI::Form::ArrayField::Component",
    autocomplete_component:          "UI::Form::Autocomplete::Component",
    form_block_component:            "UI::Form::Block::Component",
    checkboxes_component:            "UI::Form::Checkboxes::Component",
    hidden_field_component:          "UI::Form::HiddenField::Component",
    password_field_component:        "UI::Form::PasswordField::Component",
    radio_buttons_component:         "UI::Form::RadioButtons::Component",
    search_form_component:           "UI::Form::SearchForm::Component",
    icon_component:                  "UI::Icon::Component",
    logs_component:                  "UI::Logs::Component",
    modal_component:                 "UI::Modal::Component",
    modal_call_component:            "UI::ModalCall::Component",
    noscript_component:              "UI::Noscript::Component",
    notification_component:          "UI::Notification::Component",
    table_component:                 "UI::Table::Component",
    tabs_component:                  "UI::Tabs::Component",
    timeline_component:              "UI::Timeline::Component",
    audits_list_component:           "Views::Audits::ListComponent",
    priority_badge:                  "Views::Reports::PriorityBadge::Component",
    report_status_badge:             "Views::Reports::StatusBadge::Component"
  }.each do |method_name, component_class_name|
    define_method method_name do |*args, **kwargs, &block|
      render component_class_name.constantize.new(*args, **kwargs), &block
    end
  end
end
