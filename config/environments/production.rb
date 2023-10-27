# frozen_string_literal: true

require "active_support/core_ext/integer/time"

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # Code is not reloaded between requests.
  config.cache_classes = true

  # Eager load code on boot. This eager loads most of Rails and
  # your application in memory, allowing both threaded web servers
  # and those relying on copy on write to perform better.
  # Rake tasks automatically ignore this option for performance.
  config.eager_load = true

  # Full error reports are disabled and caching is turned on.
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Ensures that a master key has been made available in either ENV["RAILS_MASTER_KEY"]
  # or in config/master.key. This key is used to decrypt credentials (and other encrypted files).
  config.require_master_key = true

  # Disable serving static files from the `/public` folder by default since
  # Apache or NGINX already handles this.
  config.public_file_server.enabled = ENV["RAILS_SERVE_STATIC_FILES"].present?

  # Compress CSS using a preprocessor.
  # config.assets.css_compressor = :sass

  # Do not fallback to assets pipeline if a precompiled asset is missed.
  config.assets.compile = false

  # Enable serving of images, stylesheets, and JavaScripts from an asset server.
  # config.asset_host = "http://assets.example.com"
  config.asset_host = ENV["RAILS_ASSET_HOST"] if ENV["RAILS_ASSET_HOST"]

  # Specifies the header that your server uses for sending files.
  # config.action_dispatch.x_sendfile_header = "X-Sendfile" # for Apache
  # config.action_dispatch.x_sendfile_header = "X-Accel-Redirect" # for NGINX
  config.action_dispatch.x_sendfile_header = ENV["RAILS_X_SENDFILE"] if ENV["RAILS_X_SENDFILE"]

  if ENV["CC_INTERNAL_LOCATION"] && ENV["RAILS_X_SENDFILE"]
    internal, external = ENV["CC_INTERNAL_LOCATION"].split(":")
    internal = Rails.root.join(internal.gsub(%r{^/}, ""))

    x_sendfile_header  = ENV.fetch("RAILS_X_SENDFILE")
    x_sendfile_mapping = [[internal, external]]

    config.middleware.swap Rack::Sendfile, Rack::Sendfile, x_sendfile_header, x_sendfile_mapping
  end

  # Store uploaded files on the local file system (see config/storage.yml for options).
  config.active_storage.service = :cellar

  # Mount Action Cable outside main process or domain.
  # config.action_cable.mount_path = nil
  # config.action_cable.url = "wss://example.com/cable"
  # config.action_cable.allowed_request_origins = [ "http://example.com", /http:\/\/example.*/ ]

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  config.force_ssl = ENV["RAILS_FORCE_SSL"].present?

  # Include generic and useful information about system operation, but avoid logging too much
  # information to avoid inadvertent exposure of personally identifiable information (PII).
  config.log_level = ENV["RAILS_LOGGER_LEVEL"]&.to_sym || :info

  # Prepend all log lines with the following tags.
  config.log_tags = %i[request_id remote_ip]

  # Use a different cache store in production.
  # config.cache_store = :mem_cache_store
  config.cache_store = :redis_cache_store, { url: ENV.fetch("REDIS_CACHE_URL") } if ENV["REDIS_CACHE_URL"]

  # Use a real queuing backend for Active Job (and separate queues per environment).
  # config.active_job.queue_adapter     = :resque
  # config.active_job.queue_name_prefix = "passerelle_production"

  config.action_mailer.perform_caching = false

  # Ignore bad email addresses and do not raise email delivery errors.
  # Set this to true and configure the email server for immediate delivery to raise delivery errors.
  # config.action_mailer.raise_delivery_errors = false

  config.action_mailer.delivery_method     = :smtp
  config.action_mailer.smtp_settings       = Rails.application.credentials.smtp_settings
  config.action_mailer.default_url_options = { host: config.x.domain }

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation cannot be found).
  config.i18n.fallbacks = true

  # Don't log any deprecations.
  config.active_support.report_deprecations = false

  # Use default logging formatter so that PID and timestamp are not suppressed.
  config.log_formatter = Logger::Formatter.new

  # Use a different logger for distributed setups.
  # require "syslog/logger"
  # config.logger = ActiveSupport::TaggedLogging.new(Syslog::Logger.new "app-name")

  if ENV["RAILS_LOG_TO_STDOUT"].present?
    logger           = ActiveSupport::Logger.new($stdout)
    logger.formatter = config.log_formatter
    config.logger    = ActiveSupport::TaggedLogging.new(logger)
  end

  # Do not dump schema after migrations.
  config.active_record.dump_schema_after_migration = false

  # Add trusted IP from reverse proxy
  # See https://api.rubyonrails.org/classes/ActionDispatch/RemoteIp/GetIp.html#method-i-calculate_ip
  if ENV["CC_REVERSE_PROXY_IPS"].present?
    config.action_dispatch.trusted_proxies = ENV["CC_REVERSE_PROXY_IPS"].split(",").map { |proxy| IPAddr.new(proxy) }
  end

  # Handle few redirections
  config.middleware.insert_before Rack::Runtime, Rack::Rewrite do
    r301(/.*/, "//fiscahub.fr$&", host: "www.fiscahub.fr")
  end
end
