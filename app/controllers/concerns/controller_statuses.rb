# frozen_string_literal: true

module ControllerStatuses
  InterruptAction = Class.new(StandardError)

  private

  %i[
    bad_request
    unauthorized
    not_acceptable
    forbidden
    not_found
    gone
    unprocessable_content
    not_implemented
    internal_server_error
  ].each do |status|
    define_method status do |_exception = nil, **options|
      render_status(status, **options)
    end

    define_method :"#{status}!" do |error_message = nil|
      render_status(status, error: error_message)
      raise InterruptAction
    end
  end

  def forbidden(exception = nil)
    @reason = exception
    if exception.is_a? ControllerVerifyIp::UnauthorizedIp
      render_status(:forbidden, layout: "public")
    else
      render_status(:forbidden, layout: "application")
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

  def expired_session
    respond_to do |format|
      format.html do
        stored_location_for(:user)
        redirect_to new_session_path(:user), notice: I18n.t("status.expired_session")
      end
      format.any do
        render_status(:unauthorized)
      end
    end
  end

  def render_status(status, error: nil, **)
    respond_to do |format|
      format.html do
        if turbo_frame_request_id == "modal"
          request.variant = :modal
          @referrer_path = referrer_path
        end

        render(status:, action: status, **)
      rescue ActionView::MissingTemplate
        render(status:, template: "shared/statuses/#{status}", **)
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
