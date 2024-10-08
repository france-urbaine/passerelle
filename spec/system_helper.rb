# frozen_string_literal: true

# Load general RSpec Rails configuration
require "rails_helper"

ENV["WEBDRIVER"] ||= "cuprite"

# Load configuration files and helpers
Rails.root.glob("spec/support/system/**/*.rb").each { |file| require file }

RSpec.configure do |config|
  # Helpers & matchers from gems
  #
  config.include Devise::Test::IntegrationHelpers, type: :system

  # Custom helpers
  #
  config.include SystemTestHelpers, type: :system

  # System specs use fixtures.
  # Instead of using transactional fixtures, we'll use DataCleaner around each
  # context to cleanup data.
  #
  config.fixture_paths = [
    Rails.root.join("spec/fixtures/records")
  ]

  # Configure database cleaning strategy
  #
  config.before :context, type: :system do
    self.use_transactional_tests = false

    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.start
  end

  config.after :context, type: :system do
    DatabaseCleaner.clean
  end

  # Set default host to the right URL when using `_url` routes helpers in system specs
  #
  config.around :each, type: :system do |example|
    previous_host = Rails.application.routes.default_url_options[:host]
    Rails.application.routes.default_url_options[:host] = Capybara.app_host
    example.run
    Rails.application.routes.default_url_options[:host] = previous_host
  end

  # Make urls in mailers contain the correct server host.
  # This is required for testing links in emails (e.g., via capybara-email).
  #
  config.around :each, type: :system do |example|
    previous_host = Rails.application.default_url_options[:host]
    Rails.application.default_url_options[:host] = Capybara.app_host
    example.run
    Rails.application.default_url_options[:host] = previous_host
  end
end
