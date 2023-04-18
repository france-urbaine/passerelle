# frozen_string_literal: true

RSpec.configure do |config|
  config.before :context, use_fixtures: true do
    self.use_transactional_tests = false
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.start
  end

  config.after :context, use_fixtures: true do
    DatabaseCleaner.clean
  end
end
