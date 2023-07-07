# frozen_string_literal: true

module TemplateStatus
  # @logical_path Templating
  # @display frame false
  #
  class ComponentPreview < ViewComponent::Preview
    DEFAULT_REFERRER = "/rails/view_components/samples/turbo/card"

    # @label Default
    # @param modal toggle "View the template when requesting a modal"
    # @param referrer text "Referrer URL (rendered in background of a modal)"
    #
    def default(modal: false, referrer: DEFAULT_REFERRER)
      render_with_template(locals: { modal:, referrer: })
    end

    # @label 404 Not Found
    # @param modal toggle "View the template when requesting a modal"
    # @param referrer text "Referrer URL (rendered in background of a modal)"
    # @param model select { choices: [user, publisher, collectivity, other] } "Model not found"
    #
    def not_found(modal: false, referrer: DEFAULT_REFERRER, model: "user")
      model_not_found = model.classify

      render_with_template(locals: { modal:, referrer:, model_not_found: })
    end

    # @label 410 Gone
    # @param modal toggle "View the template when requesting a modal"
    # @param referrer text "Referrer URL (rendered in background of a modal)"
    # @param model select { choices: [user, publisher, collectivity, other] } "Gone record"
    #
    def gone(modal: false, referrer: DEFAULT_REFERRER, model: "user")
      gone_record = ::FactoryBot.build_stubbed(model, :discarded) unless model == "other"

      render_with_template(locals: { modal:, referrer:, gone_record: })
    end
  end
end
