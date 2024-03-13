# frozen_string_literal: true

source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.3.0"

# Core gems
gem "bootsnap", require: false
gem "puma", "~> 6.0"
gem "rails", "~> 7.1.0"

# Database
gem "fx"
gem "pg", "~> 1.1"
gem "redis", "~> 5.0"

# Asynchronous adapater
gem "sidekiq"

# API
gem "apipie-rails"
gem "doorkeeper"
gem "doorkeeper-i18n"

# Models
gem "devise"
gem "devise_zxcvbn"
# https://github.com/tinfoil/devise-two-factor/pull/240
gem "devise-two-factor", github: "inkstak/devise-two-factor", branch: "bugfix-insert_two_factor_authenticatable_on_top"
gem "discard"
gem "zxcvbn"

# Storage
gem "aws-sdk-s3", require: false

# Controllers
gem "action_policy"
gem "pagy"
gem "responders"

# Assets
gem "cssbundling-rails"
gem "inline_svg"
gem "jsbundling-rails"
gem "premailer-rails"
gem "rqrcode"
gem "sprockets-rails"
gem "stimulus-rails"
gem "turbo-rails"

# Views
gem "jbuilder"
gem "rails-i18n"
gem "slim"
gem "view_component"
gem "view_component-contrib"

# Data tools
gem "faker"
gem "roo"
gem "rubyzip"

# Production config & monitoring
gem "appsignal"
gem "lograge"
gem "rack-attack"
gem "rack-rewrite"

# Windows compatibility
gem "tzinfo-data", platforms: %i[mingw mswin x64_mingw jruby]

gem "audited"

group :development, :test do
  gem "lookbook", ">= 2.0.0"

  # FIXME: waiting for this PR to be released
  # The gem can be removed from the Gemfile after release because
  # its already a dependency of lookbook
  # https://github.com/threedaymonk/htmlbeautifier/pull/74
  gem "htmlbeautifier", github: "inkstak/htmlbeautifier", branch: "allow_custom_elements"

  gem "awesome_print"
  gem "byebug"
  gem "dead_end"
  gem "debug", platforms: %i[mri mingw x64_mingw]
  gem "dotenv"

  # Test frameworks
  gem "factory_bot"
  gem "factory_bot-awesome_linter"
  gem "factory_bot_rails"
  gem "rspec"
  gem "rspec-rails"

  # Parallel testing
  gem "parallel_tests"
  gem "turbo_tests", github: "inkstak/turbo_tests", branch: "feature-handle_fuubar"
end

group :development do
  gem "actual_db_schema"
  gem "annotate"
  gem "rack-mini-profiler"
  gem "web-console"

  # Linting
  gem "erb_lint",            require: false
  gem "rubocop",             require: false
  gem "rubocop-capybara",    require: false
  gem "rubocop-factory_bot", require: false
  gem "rubocop-performance", require: false
  gem "rubocop-rails",       require: false
  gem "rubocop-rake",        require: false
  gem "rubocop-rspec",       require: false

  # Tests & lint automation
  gem "guard"
  gem "guard-brakeman", require: false
  # FIXME: waiting for this PR to be released
  # https://github.com/Driversnote-Dev/guard-erb_lint/pull/2
  gem "guard-erb_lint", require: false, github: "Driversnote-Dev/guard-erb_lint"
  gem "guard-rspec",    require: false
  gem "guard-rubocop",  require: false

  # Audit dependencies and common vulnerabilities
  gem "brakeman"
  gem "bundler-audit"
  gem "bundleup"

  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"
end

group :test do
  # Test helpers
  gem "database_cleaner"
  gem "database_cleaner-active_record"
  gem "timecop"
  gem "webmock"

  # RSpec extensions
  gem "fuubar"
  gem "rspec-collection_matchers"
  gem "saharspec"
  gem "shoulda-matchers"
  gem "super_diff"

  # Test analysis
  gem "rspec-github", require: false
  gem "simplecov", require: false

  # System tests
  gem "capybara"
  gem "cuprite"

  # Alternative system test browser
  # gem "webdrivers", ">= 5.3.0"

  # Analyse and improve test performances
  gem "test-prof"
end
