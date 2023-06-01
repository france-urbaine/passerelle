# frozen_string_literal: true

Rails.application.configure do
  config.lograge.enabled = !Rails.env.development? || ENV["LOGRAGE_IN_DEVELOPMENT"] == "true"
end
