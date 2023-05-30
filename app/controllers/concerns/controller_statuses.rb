# frozen_string_literal: true

module ControllerStatuses
  private

  %i[
    bad_request
    unauthorized
    forbidden
    not_acceptable
    unprocessable_entity
    not_implemented
  ].each do |status|
    define_method(status) do
      render_status(status)
    end
  end

  def not_found(exception = nil)
    @model_not_found = exception&.model
    render_status(:not_found)
  end

  def gone(argument = nil)
    @gone_record = argument
    @gone_record = argument.record if argument.is_a?(ControllerDiscard::RecordDiscarded)
    render_status(:gone)
  end

  def render_status(status)
    if turbo_frame_request_id == "modal"
      request.variant = :modal
      @background_url = referrer_path
    end

    respond_to do |format|
      format.html { render status: status, template: "shared/statuses/#{status}" }
      format.all { head status }
    end
  end
end
