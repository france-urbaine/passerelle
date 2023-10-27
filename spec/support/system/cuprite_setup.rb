# frozen_string_literal: true

# First, load Cuprite Capybara integration
# If cuprite is replaced by webdrivers, ignore this file
begin
  require "capybara/cuprite"
rescue LoadError
  return
end

# Then, we need to register our driver to be able to use it later
# with #driven_by method.#
# NOTE: The name :cuprite is already registered by Rails.
# See https://github.com/rubycdp/cuprite/issues/180
Capybara.register_driver(:better_cuprite) do |app|
  Capybara::Cuprite::Driver.new(
    app,
    window_size: [1280, 800],
    # See additional options for Dockerized environment in the respective section of this article
    browser_options: {},
    # Increase Chrome startup wait time (required for stable CI builds)
    process_timeout: 10,
    # Enable debugging capabilities
    inspector: true,
    # Allow running Chrome in a headful mode by setting HEADLESS env
    # var to a falsey value
    headless: ENV["HEADLESS"] != "false"
  )
end

# Configure Capybara to use :better_cuprite driver by default
Capybara.default_driver = Capybara.javascript_driver = :better_cuprite

module CupriteHelpers
  # Drop #pause anywhere in a test to stop the execution.
  # Useful when you want to checkout the contents of a web page in the middle of a test
  # running in a headful mode.
  def pause
    page.driver.pause
  end

  # Drop #debug anywhere in a test to open a Chrome inspector and pause the execution
  def debug(...)
    page.driver.debug(...)
  end
end

RSpec.configure do |config|
  config.include CupriteHelpers, type: :system

  config.prepend_before :each, type: :system do
    driven_by Capybara.javascript_driver
  end
end
