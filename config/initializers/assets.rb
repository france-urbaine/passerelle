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

# Remove actiontext from precompiled assets
Rails.application.config.after_initialize do
  Rails.application.config.assets.precompile.delete("actiontext.js")
  Rails.application.config.assets.precompile.delete("trix.js")
  Rails.application.config.assets.precompile.delete("trix.css")
end

# Setup inline_svg to cache SVG icons in production
require "extras/icon_file_loader"

InlineSvg.configure do |config|
  config.asset_file = IconFileLoader.new(cache: true)
end
