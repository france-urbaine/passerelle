# frozen_string_literal: true

require_relative "boot"

require "rails/all"
require "active_storage/engine"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

if defined?(Dotenv)
  require_relative "../lib/dotenv/custom"
  require_relative "../lib/dotenv/output"
end

module Passerelle
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.2

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets dotenv tasks guard])

    # Autoload extra classes defined in lib/extras
    config.autoload_paths << "#{root}/lib/extras"

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # Avoid generating useless files with controllers
    config.generators do |g|
      g.helper = false
      g.assets = false
      g.orm :active_record, primary_key_type: :uuid
    end

    # Default (and only) locale
    config.i18n.default_locale = :fr
    config.i18n.available_locales = %i[fr]

    # FIXME: Faker will fail to generate some data when enforcing
    # locales to the one available.
    # See https://github.com/faker-ruby/faker/issues/278#issuecomment-519453199
    config.i18n.enforce_available_locales = false

    # We want to be able to use any feature of our database,
    # and the SQL format makes that possible
    config.active_record.schema_format = :sql

    # Routes exceptions tp ApplicationController via config/routes
    config.exceptions_app = routes

    # Use a real queuing backend for Active Job
    config.active_job.queue_adapter = :sidekiq

    # Active Record Encryption now uses SHA-256 as its hash digest algorithm.
    # See: https://github.com/rails/rails/issues/50226#issuecomment-1836087190
    #      https://github.com/rails/rails/issues/50212#issuecomment-1908886252
    #
    # Because, we have encrypted data from Rails 7.0, we need to configure these
    # two behaviors:
    config.active_record.encryption.hash_digest_class = OpenSSL::Digest::SHA256
    config.active_record.encryption.support_sha1_for_non_deterministic_encryption = true

    # Define default domain.
    # This is used to allowlist hosts and generate some hard links (see config.action_mailer.default_url_options)
    #
    # In production, DOMAIN_APP is mandatory.
    # In development, we encourages you to use `passerelle-fiscale.localhost` to navigate between subdomains
    # out of the box.
    #
    config.x.domain = ENV.fetch("DOMAIN_APP") do
      Rails.env.production? ? "passerelle-fiscale.fr" : "passerelle-fiscale.localhost"
    end

    config.hosts << ".#{config.x.domain}"
    config.hosts << ".example.com" if Rails.env.test?

    # When the app domain is already a sub-domain (such as alpha.passerelle-fiscale.fr),
    # we need to redefine the TLD length to let rails known how to use proper
    # subdomains constraints in routes.
    # Exemple:
    #
    #   DOMAIN_APP = alpha.passerelle-fiscale.fr
    #   DOMAIN_TLD_LENGTH = 2
    #
    # The TLD length is already calculated by default in most cases.
    #
    config.action_dispatch.tld_length = ENV.fetch("DOMAIN_TLD_LENGTH") {
      length = config.x.domain.split(".").size
      length -= 1 if length > 1
      length
    }.to_i

    # Session are linked to default domain (DOMAIN_APP)
    # To share cookies between two main domains (passerelle-fiscale.fr & alpha.passerelle-fiscale.fr),
    # you may define the same DOMAIN_COOKIE:
    #
    # - production:
    #   DOMAIN_APP = passerelle-fiscale.fr
    #
    # - staging:
    #   DOMAIN_APP = alpha.passerelle-fiscale.fr
    #   DOMAIN_COOKIE = passerelle-fiscale.fr
    #
    config.session_store :active_record_store,
      key:        "_passerelle_session",
      domain:     ENV.fetch("DOMAIN_COOKIE", :all),
      tld_length: 2

    # Application-wide constants
    VERSION = ENV.fetch("APP_VERSION") do
      `git describe --tags --abbrev=0`.strip
    end

    # The following URLs may expire.
    # You can find new links on the following pages:
    #   - https://www.insee.fr/fr/information/7671844
    #   - https://www.insee.fr/fr/information/2510634
    #
    COMMUNES_INSEE_INFO_URL = "https://www.insee.fr/fr/information/7671844"
    EPCI_INSEE_INFO_URL     = "https://www.insee.fr/fr/information/2510634"

    DEFAULT_COMMUNES_URL = "https://www.insee.fr/fr/statistiques/fichier/7671844/table-appartenance-geo-communes-2024.zip"
    DEFAULT_EPCIS_URL    = "https://www.insee.fr/fr/statistiques/fichier/2510634/epci_au_01-01-2024.zip"
  end
end
