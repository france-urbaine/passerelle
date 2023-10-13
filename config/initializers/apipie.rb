# frozen_string_literal: true

Apipie.configure do |config|
  config.app_name                = "Fiscahub"
  config.api_base_url            = ""
  config.doc_base_url            = "/documentation/references"
  config.default_locale          = "fr"
  config.validate                = false
  config.layout                  = "documentation"
  config.api_controllers_matcher = Rails.root.join("app/controllers/api/*.rb").to_s
end
