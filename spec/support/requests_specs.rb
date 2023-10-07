# frozen_string_literal: true

module RequestSpecsMacros
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
  config.include RequestSpecsMacros, type: :request

  # Set default host for routing & request specs
  #
  config.before type: :request do
    host! "example.com"
  end

  config.before type: :request, api: true do
    host! "api.example.com"
  end
end
