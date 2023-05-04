# frozen_string_literal: true

# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= "test"
require "spec_helper"

unless ENV["SIMPLE_COV"] == "false"
  require "simplecov"

  SimpleCov.start "rails" do
    # When runnning `bin/ci` unit tests and system tests are ran in two separate processes.
    # To merge both coverage results, we need to setup a custom command:
    command_name ENV["SIMPLE_COV_COMMAND"] if ENV.key?("SIMPLE_COV_COMMAND")

    add_group "Components", "app/components"
    add_group "Services", "app/services"
  end
end

require File.expand_path("../config/environment", __dir__)

# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?
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
Dir[Rails.root.join("spec/support/**/*.rb")].each do |file|
  # Files in support/system should be required from system_helper.rb
  require file unless file.include?("spec/support/system")
end

# Checks for pending migrations and applies them before tests are run.
# If you are not using ActiveRecord, you can remove these lines.
begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  puts e.to_s.strip
  exit 1
end

RSpec.configure do |config|
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
  config.include Matchers::HaveFlash
  config.include Matchers::HaveSentEmails
  config.include Matchers::PerformSQLQueries
  config.include Matchers::HaveHTMLAttribute, type: :component
  config.include Matchers::RenderPreviewWithoutException, type: :component

  config.include ViewComponent::TestHelpers, type: :component
  config.include Capybara::RSpecMatchers, type: :component
  config.include ActionView::Helpers::TagHelper, type: :component

  config.after do
    ActionMailer::Base.deliveries.clear
    Faker::UniqueGenerator.clear
  end

  # Forbid any outbound HTTP requests when running tests
  #
  config.before do
    WebMock.disable_net_connect!(allow_localhost: true)
  end

  # Allow to use a cache store within tests by using metadata:
  #
  #    context "with cache store", cache_store: :memory_store do
  #      # ...
  #    end
  #
  config.around :each, :cache_store do |example|
    previous_cache = Rails.cache

    cache_store = example.metadata[:cache_store]
    Rails.cache = ActiveSupport::Cache.lookup_store(cache_store)
    example.run
    Rails.cache.clear
    Rails.cache = previous_cache
  end
end

# Declare negative matchers to use with operands.
# Example:
#
#   expect(..)
#     .to include(..)
#     .and not_include(...)
#
#   expect { .. }
#     .to change(..)
#     .and not_change(...)
#
RSpec::Matchers.define_negated_matcher :not_be_a,              :be_a
RSpec::Matchers.define_negated_matcher :not_be_an,             :be_an
RSpec::Matchers.define_negated_matcher :not_include,           :include
RSpec::Matchers.define_negated_matcher :not_change,            :change
RSpec::Matchers.define_negated_matcher :not_raise_error,       :raise_error
RSpec::Matchers.define_negated_matcher :not_have_enqueued_job, :have_enqueued_job
RSpec::Matchers.define_negated_matcher :be_unroutable,         :be_routable
