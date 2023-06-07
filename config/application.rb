# frozen_string_literal: true

require_relative "boot"

require "rails/all"
require "active_storage/engine"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Fiscahub
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # Avoid generating useless files with controllers
    config.generators.helper = false
    config.generators.assets = false
    config.generators.template_engine = :slim

    # Default (and only) locale
    config.i18n.default_locale = :fr

    # We want to be able to use any feature of our database,
    # and the SQL format makes that possible
    config.active_record.schema_format = :sql
  end
end
