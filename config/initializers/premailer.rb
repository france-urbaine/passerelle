Premailer::Rails.config.merge!(
  base_url: ENV.fetch("RAILS_ASSET_HOST") { "http://localhost:#{ENV.fetch("PORT", 3000)}" if Rails.env.development? },
)