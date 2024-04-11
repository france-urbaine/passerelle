# frozen_string_literal: true

require "action_policy/rspec"
require "action_policy/rspec/dsl"

RSpec.configure do |config|
  # Shared contexts & examples
  #
  config.include PolicyTestHelpers::ScopesHelpers,      type: :policy
  config.include PolicyTestHelpers::SharedUserContexts, type: :policy
end
