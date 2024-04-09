# frozen_string_literal: true

RSpec.configure do |config|
  # Helpers & matchers from gems
  #
  config.include Capybara::RSpecMatchers,          type: :request
  config.include Devise::Test::IntegrationHelpers, type: :request

  # Custom matchers
  #
  config.include Matchers::HaveBody,        type: :request
  config.include Matchers::HaveContentType, type: :request
  config.include Matchers::HaveFlash,       type: :request

  # Custom helpers
  #
  config.include RequestTestHelpers::AuthenticationHelpers, type: :request
  config.include RequestTestHelpers::DomHelpers,            type: :request
  config.include RequestTestHelpers::ImplicitHelpers,       type: :request
  config.include RequestTestHelpers::InspectHTML,           type: :request

  # Shared contexts & examples
  #
  config.include RequestTestHelpers::SharedAuthorizationContexts, type: :request
  config.include RequestTestHelpers::SharedResponseExamples,      type: :request

  # Set default host for routing & request specs
  #
  config.before type: :request do
    host! "example.com"
  end

  config.before type: :request, api: true do
    host! "api.example.com"
  end
end

# FIXME: https://github.com/rails/rails/issues/50345
ActionDispatch::IntegrationTest.register_encoder :html,
  response_parser: ->(body) { Rails::Dom::Testing.html_document.parse(body) },
  param_encoder: ->(params) { params }
