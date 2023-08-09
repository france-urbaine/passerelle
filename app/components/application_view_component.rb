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

  # Devise & ActionPolicy helpers
  delegate :current_user, :current_organization, :signed_in?, :allowed_to?, to: :helpers

  # Helpers methods
  delegate :svg_icon, :authorized_link_to, to: :helpers

  # Other component helpers
  delegate :template_modal_component, :template_content_component, to: :helpers

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

  def turbo_frame_request_id
    request.headers["Turbo-Frame"]
  end

  def turbo_frame_request?
    turbo_frame_request_id.present?
  end
end
