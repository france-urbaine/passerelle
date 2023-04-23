# frozen_string_literal: true

# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = "1.0"

# Add additional assets to the asset load path.
# Rails.application.config.assets.paths << Emoji.images_path

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in the app/assets
# folder are already added.
# Rails.application.config.assets.precompile += %w( admin.js admin.css )

InlineSvg.configure do |config|
  if Rails.env.production?
    config.asset_file = InlineSvg::CachedAssetFile.new(
      paths: [Rails.root.join("app/assets/icons")],
      filters: /\.svg/
    )
  end
end
