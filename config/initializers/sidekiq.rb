# frozen_string_literal: true

Sidekiq.default_job_options = { "backtrace" => 200 }

redis_options = {}
redis_options = { db: 14 } if Rails.env.test?
redis_options = { url: ENV["REDIS_SIDEKIQ_URL"] } if ENV.key?("REDIS_SIDEKIQ_URL")
redis_options[:timeout] = 3 if Rails.env.production?

Sidekiq.configure_client do |config|
  config.redis = redis_options
  config.logger = Rails.logger if Rails.env.test? && ENV["CI_LESS_OUTPUT"] == "true"
end

Sidekiq.configure_server do |config|
  config.redis = redis_options
end
