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

    # Routes exceptions tp ApplicationController via config/routes
    config.exceptions_app = routes

    # Autoload extra classes defined in lib/extra
    config.autoload_paths << "#{root}/lib/extras"

    # Use a real queuing backend for Active Job
    config.active_job.queue_adapter = :sidekiq

    # Define domain strategy.
    # Default domain is `localhost`
    #
    # To be able to use subdomains (such as api.), you need a domain with a longer TLD.
    # For example, use:
    #
    #   DOMAIN_APP = localhost.local
    #
    # You'll then be able to run api.localhost.local
    #
    unless Rails.env.test?
      config.x.domain = ENV.fetch("DOMAIN_APP", "localhost")
      config.hosts << ".#{config.x.domain}"
    end

    # If your main domain is already a subdomain (such as alpha.fiscahub.fr),
    # you should also define TLD length:
    #
    #   DOMAIN_APP = alpha.fiscahub.fr
    #   DOMAIN_TLD_LENGTH = 2
    #
    config.action_dispatch.tld_length = Integer(ENV["DOMAIN_TLD_LENGTH"] || 1)

    # Session are linked to default domain (DOMAIN_APP)
    # To share cookies between two main domains (fiscahub.fr & alpha.fiscahub.fr),
    # you may define the same DOMAIN_COOKIE:
    #
    # - production:
    #   DOMAIN_APP = fiscahub.fr
    #
    # - staging:
    #   DOMAIN_APP = alpha.fiscahub.fr
    #   DOMAIN_COOKIE = fiscahub.fr
    #
    config.session_store :cookie_store,
      key:        "_fiscahub_session",
      domain:     ENV.fetch("DOMAIN_COOKIE", :all),
      tld_length: 2

    # Application-wide constants
    DEFAULT_COMMUNES_URL = "https://www.insee.fr/fr/statistiques/fichier/2028028/table-appartenance-geo-communes-23.zip"
    DEFAULT_EPCIS_URL    = "https://www.insee.fr/fr/statistiques/fichier/2510634/Intercommunalite_Metropole_au_01-01-2023.zip"
  end
end
