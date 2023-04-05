# frozen_string_literal: true

class ApplicationResponder < ActionController::Responder
  include Responders::FlashResponder
  include Responders::HttpCacheResponder

  # Redirects resources to the collection path (index action) instead
  # of the resource path (show action) for POST/PUT/DELETE requests.
  # include Responders::CollectionResponder

  # Configure default status codes for responding to errors and redirects.
  self.error_status = :unprocessable_entity
  self.redirect_status = :see_other

  # Allow new options to be passed to responders
  def initialize(controller, resources, options = {})
    super
    @flash_actions = Array.wrap(options.delete(:actions))
  end

  # Add flash actions to  message to include undo action
  #
  def set_flash_message!
    super
    return if @flash_actions.empty?

    flash = controller.flash
    flash = flash.now if set_flash_now?
    flash[:actions] = FlashAction.write_multi(@flash_actions)
  end
end
