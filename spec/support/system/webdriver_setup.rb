# frozen_string_literal: true

# If webdriver is replaced by cuprite, ignore this file
return unless defined?(Webdrivers)

RSpec.configure do |config|
  config.before type: :system do
    WebMock.disable_net_connect!(
      net_http_connect_on_start: true,
      allow_localhost:           true,
      allow:                     /geckodriver/
    )

    driven_by :selenium,
      using: ENV.fetch("WEBDRIVER", "headless_firefox").to_sym,
      screen_size: [1200, 800]
  end
end
