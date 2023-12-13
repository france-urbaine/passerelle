# frozen_string_literal: true

# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= "test"
require "spec_helper"
require "simplecov" unless ENV["SIMPLE_COV"] == "false"

require File.expand_path("../config/environment", __dir__)

# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?

# Add additional requires below this line. Rails is not loaded until this point!
require "rspec/rails"
require "webmock/rspec"
require "database_cleaner/active_record"
require "view_component/test_helpers"
require "action_policy/rspec"
require "action_policy/rspec/dsl"
require "test_prof/recipes/rspec/before_all"
require "test_prof/recipes/rspec/let_it_be"

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
  config.include Matchers::BeANullRelation
  config.include Matchers::Invoke
  config.include Matchers::HaveBody
  config.include Matchers::HaveContentType
  config.include Matchers::HaveFlash
  config.include Matchers::HaveSentEmails
  config.include Matchers::PerformSQLQueries
  config.include Matchers::HaveHTMLAttribute, type: :component
  config.include Matchers::HaveHTMLAttribute, type: :helper
  config.include Matchers::RenderPreviewWithoutException, type: :component
  config.include Capybara::RSpecMatchers, type: :request
  config.include Capybara::RSpecMatchers, type: :component
  config.include ViewComponent::TestHelpers, type: :component
  config.include ActionView::Helpers::TagHelper, type: :component
  config.include ActiveJob::TestHelper

  # run specs with APIPIE_RECORD=examples to catch examples for api doc
  config.filter_run show_in_doc: true if ENV["APIPIE_RECORD"]

  # Enable failure aggregation globally on given spec types
  config.define_derived_metadata do |meta|
    meta[:aggregate_failures] = true if meta[:type] == :component
  end

  config.after do
    ActionMailer::Base.deliveries.clear
    ActiveJob::Base.queue_adapter.enqueued_jobs.clear
    ActiveJob::Base.queue_adapter.performed_jobs.clear
    Faker::UniqueGenerator.clear
  end

  # Forbid any outbound HTTP requests when running tests
  #
  config.before do
    WebMock.disable_net_connect!(allow_localhost: true)
  end

  config.around :each, type: :component do |example|
    # Some components might requires a routed path to be set
    # (for examples, when using `url_for`).
    #
    # So we created a route only available in test environnement
    # to ensure that tests are independant from any behavior linked to URL.
    #
    with_request_url("/test/components") do
      example.run
    end
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

  # Always make Timecop returns to current time
  config.after do |example|
    Timecop.return unless example.metadata[:prevent_timecop_to_return]
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
RSpec::Matchers.define_negated_matcher :not_eq,                :eq
RSpec::Matchers.define_negated_matcher :not_be_a,              :be_a
RSpec::Matchers.define_negated_matcher :not_be_an,             :be_an
RSpec::Matchers.define_negated_matcher :not_include,           :include
RSpec::Matchers.define_negated_matcher :not_change,            :change
RSpec::Matchers.define_negated_matcher :not_raise_error,       :raise_error
RSpec::Matchers.define_negated_matcher :not_invoke,            :invoke
RSpec::Matchers.define_negated_matcher :not_send_message,      :send_message
RSpec::Matchers.define_negated_matcher :not_have_enqueued_job, :have_enqueued_job
RSpec::Matchers.define_negated_matcher :not_redirect_to,       :redirect_to
RSpec::Matchers.define_negated_matcher :be_unroutable,         :be_routable

# FIXME: https://github.com/rails/rails/issues/50345
ActionDispatch::IntegrationTest.register_encoder :html,
  response_parser: ->(body) { Rails::Dom::Testing.html_document.parse(body) },
  param_encoder: ->(params) { params }
