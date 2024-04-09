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
# Matchers are required first, to avoid call require in _helper.rb files
# in support.
#
Dir[Rails.root.join("spec/support/matchers/*.rb")].each { |file| require file }
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
  # https://rspec.info/features/rspec-rails/directory-structure/
  config.infer_spec_type_from_file_location!

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!
  # arbitrary gems may also be filtered via:
  # config.filter_gems_from_backtrace("gem name")

  # Helpers from gems
  #
  config.include ActiveJob::TestHelper
  config.include FactoryBot::Syntax::Methods

  # Custom matchers available to any spec types
  #
  config.include Matchers::Invoke
  config.include Matchers::HaveSentEmails
  config.include Matchers::PerformSQLQueries

  # run specs with APIPIE_RECORD=examples to catch examples for api doc
  #
  config.filter_run show_in_doc: true if ENV["APIPIE_RECORD"]

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

  # Always make Timecop returns to current time
  #
  config.after do |example|
    Timecop.return unless example.metadata[:prevent_timecop_to_return]
  end

  # Clear & reset various stuff after running specs
  #
  config.after do
    ActionMailer::Base.deliveries.clear
    ActiveJob::Base.queue_adapter.enqueued_jobs.clear
    ActiveJob::Base.queue_adapter.performed_jobs.clear
    Faker::UniqueGenerator.clear
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
RSpec::Matchers.define_negated_matcher :not_eq,                 :eq
RSpec::Matchers.define_negated_matcher :not_be_a,               :be_a
RSpec::Matchers.define_negated_matcher :not_be_an,              :be_an
RSpec::Matchers.define_negated_matcher :not_include,            :include
RSpec::Matchers.define_negated_matcher :not_change,             :change
RSpec::Matchers.define_negated_matcher :not_raise_error,        :raise_error
RSpec::Matchers.define_negated_matcher :not_send_message,       :send_message
RSpec::Matchers.define_negated_matcher :not_have_enqueued_job,  :have_enqueued_job
RSpec::Matchers.define_negated_matcher :not_redirect_to,        :redirect_to
RSpec::Matchers.define_negated_matcher :not_have_sent_emails,   :have_sent_emails
RSpec::Matchers.define_negated_matcher :be_unroutable,          :be_routable
RSpec::Matchers.define_negated_matcher :have_no_html_attribute, :have_html_attribute
