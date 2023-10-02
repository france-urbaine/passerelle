# frozen_string_literal: true

module RequestMacros
  # Expose #dom_id helper to requests specs
  # config.include ActionView::RecordIdentifier, type: :request

  def dom_id(...)
    ActionView::RecordIdentifier.dom_id(...)
  end

  def escape_html(...)
    ERB::Util.html_escape(...)
  end
end

RSpec.configure do |config|
  config.include RequestMacros, type: :request
end
