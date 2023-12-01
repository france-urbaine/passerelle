# frozen_string_literal: true

module Layout
  # @display frame false
  #
  class StatusPageComponentPreview < ViewComponent::Preview
    DEFAULT_REFERRER = "/rails/view_components/samples/turbo/content"

    # @label Default
    # @param modal toggle "View the template when requesting a modal"
    # @param referrer text "Referrer URL (rendered in background of a modal)"
    #
    def default(modal: false, referrer: DEFAULT_REFERRER)
      render_with_template(locals: { modal:, referrer: })
    end

    # @label With breadcrumbs
    # @param modal toggle "View the template when requesting a modal"
    # @param referrer text "Referrer URL (rendered in background of a modal)"
    #
    def with_breadcrumbs(modal: false, referrer: DEFAULT_REFERRER)
      render_with_template(locals: { modal:, referrer: })
    end

    # @label 404 Not Found
    # @param modal toggle "View the template when requesting a modal"
    # @param referrer text "Referrer URL (rendered in background of a modal)"
    # @param model select { choices: [[Publisher, publisher], [Collectivity, collectivity], [User, user], other] } "Model not found"
    #
    def not_found(modal: false, referrer: DEFAULT_REFERRER, model: "user")
      model_not_found = model.classify

      render_with_template(locals: { modal:, referrer:, model_not_found: })
    end

    # @label 410 Gone
    # @param modal toggle "View the template when requesting a modal"
    # @param referrer text "Referrer URL (rendered in background of a modal)"
    # @param model select { choices: [[DDFIP, ddfip], [Office, office], ["[DDFIP, Office]", ddfip_office], [User, user], ["[Publisher, User]", publisher_user], other] } "Gone records"
    #
    def gone(modal: false, referrer: DEFAULT_REFERRER, model: "user")
      gone_records = model.split("_").filter_map do |m|
        ::FactoryBot.build_stubbed(m, :discarded) unless m == "other"
      end

      render_with_template(locals: { modal:, referrer:, gone_records: })
    end
  end
end
