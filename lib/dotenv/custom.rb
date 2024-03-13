# frozen_string_literal: true

env = ENV.fetch("DOTENV") do
  ENV.fetch("RAILS_ENV", "development")
end

Dotenv::Rails.files = [
  ".env.#{env}.local",
  (".env.local" unless env == "test"),
  ".env.#{env}",
  ".env"
].compact
