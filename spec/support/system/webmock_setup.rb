# frozen_string_literal: true

RSpec.configure do |config|
  # Forbid outbound HTTP requests when running tests
  #
  config.before type: :system do
    WebMock.disable_net_connect!(allow_localhost: true)
  end
end
