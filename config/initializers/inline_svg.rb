# frozen_string_literal: true

require "extras/icon_file_loader"
require "extras/icon_hidden_transform"
require "extras/icon_attributes_remove_transform"

InlineSvg.configure do |config|
  # Setup inline_svg to cache SVG icons in production
  config.asset_file = IconFileLoader.new(cache: true)

  # Remove default aria-hidden set by heroicons
  config.add_custom_transformation(attribute: :hidden,            transform: IconHiddenTransform)
  config.add_custom_transformation(attribute: :remove_attributes, transform: IconAttributesRemoverTransform)
end
