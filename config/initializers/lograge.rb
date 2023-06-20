# frozen_string_literal: true

Rails.application.configure do
  config.lograge.enabled = Rails.env.production? || ENV["LOGRAGE"] == "true"
  config.lograge.keep_original_rails_log = true

  if Appsignal.active?
    config.lograge.logger = Appsignal::Logger.new(
      "rails",
      format: Appsignal::Logger::LOGFMT
    )
  end

  config.lograge.custom_options = lambda do |event|
    {
      request_id: event.payload[:request_id]
    }
  end
end
