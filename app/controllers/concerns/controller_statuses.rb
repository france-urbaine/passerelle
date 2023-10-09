# frozen_string_literal: true

module ControllerStatuses
  private

  InterruptAction = Class.new(StandardError)

  %i[
    bad_request
    unauthorized
    forbidden
    not_acceptable
    unprocessable_entity
    not_implemented
    internal_server_error
  ].each do |status|
    define_method(status) do |_exception = nil, **options|
      render_status(status, **options)
    end

    define_method("#{status}!") do |error_message = nil|
      render_status(status, error: error_message)
      raise InterruptAction
    end
  end

  def not_found(exception = nil)
    @model_not_found = exception&.model
    render_status(:not_found)
  end

  def gone(exception = nil)
    @gone_records = exception&.records
    render_status(:gone)
  end

  def render_status(status, error: nil)
    respond_to do |format|
      format.html do
        if turbo_frame_request_id == "modal"
          request.variant = :modal
          @referrer_path = referrer_path
        end

        render status:, action: status
      rescue ActionView::MissingTemplate
        render status:, template: "shared/statuses/#{status}"
      end

      format.json do
        error ||= I18n.t(status, scope: "status", default: "")

        if error.present?
          render status:, json: { error: }
        else
          head status
        end
      end

      format.all { head status }
    end
  end
end
