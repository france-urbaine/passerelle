# frozen_string_literal: true

require "active_support/core_ext/integer/time"

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # Code is not reloaded between requests.
  config.enable_reloading = false

  # Eager load code on boot. This eager loads most of Rails and
  # your application in memory, allowing both threaded web servers
  # and those relying on copy on write to perform better.
  # Rake tasks automatically ignore this option for performance.
  config.eager_load = true

  # Full error reports are disabled and caching is turned on.
  config.consider_all_requests_local = false
  config.action_controller.perform_caching = true

  # Ensures that a master key has been made available in ENV["RAILS_MASTER_KEY"], config/master.key, or an environment
  # key such as config/credentials/production.key. This key is used to decrypt credentials (and other encrypted files).
  # config.require_master_key = true
  config.require_master_key = true

  # Disable serving static files from `public/`, relying on NGINX/Apache to do so instead.
  # config.public_file_server.enabled = false
  config.public_file_server.enabled = ENV["RAILS_SERVE_STATIC_FILES"].present?

  # Compress CSS using a preprocessor.
  # config.assets.css_compressor = :sass

  # Do not fall back to assets pipeline if a precompiled asset is missed.
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

  # Assume all access to the app is happening through a SSL-terminating reverse proxy.
  # Can be used together with config.force_ssl for Strict-Transport-Security and secure cookies.
  # config.assume_ssl = true

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  config.force_ssl = true

  # Skip http-to-https redirect for the default health check endpoint.
  # config.ssl_options = { redirect: { exclude: ->(request) { request.path == "/up" } } }

  # Log to STDOUT by default
  config.logger = ActiveSupport::Logger.new($stdout)
    .tap  { |logger| logger.formatter = Logger::Formatter.new }
    .then { |logger| ActiveSupport::TaggedLogging.new(logger) }

  # Prepend all log lines with the following tags.
  config.log_tags = %i[request_id remote_ip]

  # "info" includes generic and useful information about system operation, but avoids logging too much
  # information to avoid inadvertent exposure of personally identifiable information (PII). If you
  # want to log everything, set the level to "debug".
  config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "info")

  # Use a different cache store in production.
  # config.cache_store = :mem_cache_store
  config.cache_store =
    if ENV.key?("REDIS_CACHE_URL")
      [:redis_cache_store, { url: ENV.fetch("REDIS_CACHE_URL") }]
    else
      [:memory_store, { size: 64.megabytes }]
    end

  # Use a real queuing backend for Active Job (and separate queues per environment).
  # config.active_job.queue_adapter = :resque
  # config.active_job.queue_name_prefix = "passerelle_production"

  # Disable caching for Action Mailer templates even if Action Controller
  # caching is enabled.
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

  # Do not dump schema after migrations.
  config.active_record.dump_schema_after_migration = false

  # Enable DNS rebinding protection and other `Host` header attacks.
  # config.hosts = [
  #   "example.com",     # Allow requests from example.com
  #   /.*\.example\.com/ # Allow requests from subdomains like `www.example.com`
  # ]
  # Skip DNS rebinding protection for the default health check endpoint.
  # config.host_authorization = { exclude: ->(request) { request.path == "/up" } }

  # Add trusted IP from reverse proxy
  # See https://api.rubyonrails.org/classes/ActionDispatch/RemoteIp/GetIp.html#method-i-calculate_ip
  if ENV["CC_REVERSE_PROXY_IPS"].present?
    config.action_dispatch.trusted_proxies = ENV["CC_REVERSE_PROXY_IPS"].split(",").map { |proxy| IPAddr.new(proxy) }
  end

  # Redirect former domains
  #
  config.hosts << ".fiscahub.fr"
  config.middleware.insert_before Rack::Runtime, Rack::Rewrite do
    r301(/.*/, "//#{Rails.application.config.x.domain}$&", host: "fiscahub.fr")
  end
end
