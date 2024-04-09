# frozen_string_literal: true

require "view_component/test_helpers"

RSpec.configure do |config|
  # Derive the :component type for specs lying in components directory.
  #
  config.define_derived_metadata(file_path: %r{/spec/components}) do |metadata|
    metadata[:type] = :component
  end

  # Enable failure aggregation globally on component specs
  #
  config.define_derived_metadata do |meta|
    meta[:aggregate_failures] = true if meta[:type] == :component
  end

  # Helpers & matchers from gems
  #
  config.include Capybara::RSpecMatchers,         type: :component
  config.include ViewComponent::TestHelpers,      type: :component
  config.include ActionView::Helpers::TagHelper,  type: :component
  config.include Devise::Test::ControllerHelpers, type: :component

  # Custom matchers
  #
  config.include Matchers::HaveHTMLAttribute,             type: :component
  config.include Matchers::RenderPreviewWithoutException, type: :component

  # Custom helpers
  #
  config.include ComponentTestHelpers::AuthenticationHelpers, type: :component
  config.include ComponentTestHelpers::InspectHTML,           type: :component

  # To get access to Devise’s controller helper methods in tests
  # we need to setup a request
  #
  config.before :each, type: :component do
    @request = vc_test_controller.request
  end

  # Some components might requires a routed path to be set
  # (for examples, when using `url_for`).
  #
  # So we created a route only available in test environnement
  # to ensure that tests are independant from any behavior linked to URL.
  #
  config.around :each, type: :component do |example|
    with_request_url("/test/components") do
      example.run
    end
  end
end
