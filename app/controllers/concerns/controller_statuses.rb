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

  def not_found(exception_or_model = nil)
    @model_not_found =
      case exception_or_model
      when ActiveRecord::RecordNotFound then exception_or_model.model
      when ApplicationRecord            then model.name
      when String                       then model
      end

    render_status(:not_found)
  end

  def gone(exception_or_record = nil)
    @record_discarded =
      case exception_or_record
      when ControllerDiscard::RecordDiscarded then exception_or_record.record
      when ApplicationRecord then exception_or_record
      end

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
