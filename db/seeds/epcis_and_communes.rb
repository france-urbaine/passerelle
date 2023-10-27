# frozen_string_literal: true

Territories::UpdateService.new(
  communes_url: Passerelle::Application::DEFAULT_COMMUNES_URL,
  epcis_url:    Passerelle::Application::DEFAULT_EPCIS_URL
).perform_now
