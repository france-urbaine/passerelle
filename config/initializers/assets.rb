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

Rails.application.config.after_initialize do
  # Remove turbo & stimulus from precompiled assets:
  # they are compiled in application.js by esbuild
  #
  Rails.application.config.assets.precompile.delete("turbo.js")
  Rails.application.config.assets.precompile.delete("turbo.min.js")
  Rails.application.config.assets.precompile.delete("turbo.min.js.map")

  Rails.application.config.assets.precompile.delete("stimulus.js")
  Rails.application.config.assets.precompile.delete("stimulus.min.js")
  Rails.application.config.assets.precompile.delete("stimulus.min.js.map")

  # Remove actiontext:
  # we dont use it
  #
  Rails.application.config.assets.precompile.delete("actiontext.js")
  Rails.application.config.assets.precompile.delete("actiontext.esm.js")
  Rails.application.config.assets.precompile.delete("trix.js")
  Rails.application.config.assets.precompile.delete("trix.css")
end
