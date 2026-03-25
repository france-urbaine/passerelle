# frozen_string_literal: true

RSpec.configure do |config|
  config.include Matchers::HaveHTMLAttribute, type: :helper
  config.include InspectHTML::TestHelper,     type: :helper
end
