# frozen_string_literal: true

# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= "test"
require "spec_helper"
require "simplecov"

SimpleCov.start "rails" do
  add_group "Components", "app/components"
end

require File.expand_path("../config/environment", __dir__)

# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?
require "capybara/cuprite"
require "rspec/rails"
require "webmock/rspec"
require "database_cleaner/active_record"
require "view_component/test_helpers"

unless ENV.fetch("SUPER_DIFF", nil) == "false"
  require "super_diff/rspec"
  require "super_diff/rails"
end

# Add additional requires below this line. Rails is not loaded until this point!

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
#
# The following line is provided for convenience purposes. It has the downside
# of increasing the boot-up time by auto-requiring all files in the support
# directory. Alternatively, in the individual `*_spec.rb` files, manually
# require only the support files necessary.
#
Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

# Checks for pending migrations and applies them before tests are run.
# If you are not using ActiveRecord, you can remove these lines.
begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  puts e.to_s.strip
  exit 1
end

Capybara.javascript_driver = :cuprite
Capybara.register_driver(:cuprite) do |app|
  Capybara::Cuprite::Driver.new(app, window_size: [1200, 800])
end

RSpec.configure do |config|
  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = Rails.root.join("spec/fixtures/records")

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # You can uncomment this line to turn off ActiveRecord support entirely.
  # config.use_active_record = false

  # RSpec Rails can automatically mix in different behaviours to your tests
  # based on their file location, for example enabling you to call `get` and
  # `post` in specs under `spec/controllers`.
  #
  # You can disable this behaviour by removing the line below, and instead
  # explicitly tag your specs with their type, e.g.:
  #
  #     RSpec.describe UsersController, type: :controller do
  #       # ...
  #     end
  #
  # The different available types are documented in the features, such as in
  # https://relishapp.com/rspec/rspec-rails/docs
  config.infer_spec_type_from_file_location!

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!
  # arbitrary gems may also be filtered via:
  # config.filter_gems_from_backtrace("gem name")

  config.include FactoryBot::Syntax::Methods
  config.include Matchers::HaveBody
  config.include Matchers::HaveContentType
  config.include Matchers::HaveSentEmails
  config.include Matchers::PerformSQLQueries

  config.include ViewComponent::TestHelpers, type: :component
  config.include Capybara::RSpecMatchers, type: :component
  config.include ActionView::Helpers::TagHelper, type: :component

  config.include ImplicitResponse, type: :request

  config.before :context, use_fixtures: true do
    self.use_transactional_tests = false
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.start
  end

  config.after :context, use_fixtures: true do
    DatabaseCleaner.clean
  end

  config.before type: :system do
    WebMock.disable_net_connect!(
      net_http_connect_on_start: true,
      allow_localhost:           true,
      allow:                     /geckodriver/
    )

    driven_by Capybara.javascript_driver
  end

  config.after do
    ActionMailer::Base.deliveries.clear
    Faker::UniqueGenerator.clear
  end

  config.around do |example|
    timeout = ENV.fetch("TIMEOUT", 2).to_i
    Timeout.timeout(timeout) do
      example.run
    end
  end
end

RSpec::Matchers.define_negated_matcher :exclude,    :include
RSpec::Matchers.define_negated_matcher :maintain,   :change
RSpec::Matchers.define_negated_matcher :not_change, :change
RSpec::Matchers.define_negated_matcher :run_without_error, :raise_error
RSpec::Matchers.define_negated_matcher :not_raise_error,   :raise_error
RSpec::Matchers.define_negated_matcher :not_have_enqueued_job, :have_enqueued_job

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end
