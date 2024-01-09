# frozen_string_literal: true

# Usually, especially when using Selenium, developers tend to increase the max wait time.
# With Cuprite, there is no need for that.
# We use a Capybara default value here explicitly.
Capybara.default_max_wait_time = ENV.fetch("CAPYBARA_MAX_WAIT_TIME") {
  ENV["CI_PARALLEL"] ? 4 : 2
}.to_i

# Normalize whitespaces when using `has_text?` and similar matchers,
# i.e., ignore newlines, trailing spaces, etc.
# That makes tests less dependent on slightly UI changes.
Capybara.default_normalize_ws = true

# Where to store system tests artifacts (e.g. screenshots, downloaded files, etc.).
# It could be useful to be able to configure this path from the outside (e.g., on CI).
Capybara.save_path = ENV.fetch("CAPYBARA_ARTIFACTS", "./tmp/capybara")

# Raise in test suite any exception raised from server.
# Otherwise, it'll raise only exception get from browser.
Capybara.raise_server_errors = ENV.fetch("CAPYBARA_RAISE_SERVER_ERRORS", "true") == "true"

# the default host ('127.0.0.1`) does not accept subdomains.
# We need to setup a local domain that accepting subdomain.
# See config/application.rb for more details
Capybara.app_host = "http://#{Rails.application.config.x.domain}"

# To run system specs with parallel tests, we need to set up several ports to run
# concurrent headless browsers.
if ENV["TEST_ENV_NUMBER"]
  Capybara.server_port = ENV.fetch("CAPYBARA_SERVER_PORT") do
    9887 + ENV["TEST_ENV_NUMBER"].to_i
  end
end

# The Capybara.using_session allows you to manipulate a different browser session, and thus,
# multiple independent sessions within a single test scenario. That’s especially useful for
# testing real-time features, e.g., something with WebSocket.
#
# This patch tracks the name of the last session used. We’re going to use this information to
# support taking failure screenshots in multi-session tests.
#
# See https://evilmartians.com/chronicles/system-of-a-test-setting-up-end-to-end-rails-testing
#
Capybara.singleton_class.prepend(Module.new do
  attr_accessor :last_used_session

  def using_session(name, &)
    self.last_used_session = name
    super
  ensure
    self.last_used_session = nil
  end
end)

module CapybaraHelpers
  def select_option(option, from:)
    within ".autocomplete", text: from do
      find("[role=option]", text: option).click
    end
  end
end

RSpec.configure do |config|
  config.include CapybaraHelpers, type: :system

  config.before :suite do
    Rails.root.join(Capybara.save_path).glob("*").each(&:delete)
  end
end
