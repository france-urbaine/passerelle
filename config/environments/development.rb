# frozen_string_literal: true

require "active_support/core_ext/integer/time"

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded any time
  # it changes. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.enable_reloading = true

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports.
  config.consider_all_requests_local = true

  # Enable server timing
  config.server_timing = true

  # Enable/disable caching. By default caching is disabled.
  # Run rails dev:cache to toggle caching.
  if Rails.root.join("tmp/caching-dev.txt").exist?
    config.action_controller.perform_caching = true
    config.action_controller.enable_fragment_cache_logging = true
    config.public_file_server.headers = {
      "Cache-Control" => "public, max-age=#{2.days.to_i}"
    }
  else
    config.action_controller.perform_caching = false
  end

  config.cache_store = :memory_store

  # Store uploaded files on the local file system (see config/storage.yml for options).
  config.active_storage.service = :local

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false

  config.action_mailer.perform_caching = false

  config.action_mailer.default_url_options = {
    host: config.x.domain,
    port: ENV.fetch("PORT", 3000)
  }

  # Use Mailcatcher to catch emails
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
    address: "127.0.0.1",
    port: ENV.fetch("SMTP_PORT", 1025)
  }

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise exceptions for disallowed deprecations.
  config.active_support.disallowed_deprecation = :raise

  # Tell Active Support which deprecation messages to disallow.
  config.active_support.disallowed_deprecation_warnings = []

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Highlight code that triggered database queries in logs.
  config.active_record.verbose_query_logs = true

  # Highlight code that enqueued background job in logs.
  config.active_job.verbose_enqueue_logs = true

  # Suppress logger output for asset requests.
  config.assets.quiet = true

  # Raises error for missing translations.
  # config.i18n.raise_on_missing_translations = true

  # Annotate rendered view with file names.
  # config.action_view.annotate_rendered_view_with_filenames = true

  # Uncomment if you wish to allow Action Cable access from any origin.
  # config.action_cable.disable_request_forgery_protection = true

  # Raise error when a before_action's only/except options reference missing actions
  config.action_controller.raise_on_missing_callback_actions = true

  # Configure asset host to simulate CORS requests
  config.asset_host = ENV["RAILS_ASSET_HOST"] if ENV["RAILS_ASSET_HOST"]

  # Redirect localhost:3000 to appropriate domain set in config.x.domain
  # (DOMAIN_APP or `passerelle-fiscale.localhost` by default)
  #
  current_domain = Rails.application.config.x.domain
  former_domains = %w[
    localhost
    localhost.local
    fiscahub.localhost
  ]

  former_domains.each do |former_domain|
    config.hosts << ".#{former_domain}"
  end

  config.middleware.insert_before Rack::Runtime, Rack::Rewrite do
    former_domains.each do |former_domain|
      next if former_domain == current_domain

      r303(/(.*)/, lambda { |match, rack_env|
        port = rack_env["SERVER_PORT"]
        path = match.to_s
        "http://#{current_domain}:#{port}#{path}"
      }, host: former_domain)

      r303(/(.*)/, lambda { |match, rack_env|
        port = rack_env["SERVER_PORT"]
        path = match.to_s
        "http://api.#{current_domain}:#{port}#{path}"
      }, host: "api.#{former_domain}")
    end
  end
end
