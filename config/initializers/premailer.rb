# frozen_string_literal: true

Premailer::Rails.config[:base_url] = ENV.fetch("RAILS_ASSET_HOST") do
  "http://localhost:#{ENV.fetch('PORT', 3000)}" if Rails.env.development?
end
