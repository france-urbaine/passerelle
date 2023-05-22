# frozen_string_literal: true

module ControllerVariants
  private

  def accept_variant
    request.headers["Accept-Variant"]&.downcase
  end

  def autocomplete_request?
    accept_variant == "autocomplete"
  end

  def accept_request_variant
    request.variant = :turbo_frame  if turbo_frame_request?
    request.variant = :autocomplete if autocomplete_request?
  end
end
