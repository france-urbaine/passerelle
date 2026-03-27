# frozen_string_literal: true

ruby "3.4.4"
source "https://rubygems.org"

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

# Core gems
gem "bootsnap", require: false
gem "puma", "~> 7.2"
gem "rails", "~> 8.1"

# Database
gem "fx"
gem "pg", "~> 1.1"
gem "redis", "~> 5.0"

# Backend adapters
gem "activerecord-session_store"
gem "sidekiq"

# API
gem "apipie-rails"
gem "doorkeeper"
gem "doorkeeper-i18n"

# Models
gem "devise"
gem "devise-two-factor"
gem "discard"
gem "zxcvbn"

# Storage
gem "aws-sdk-s3", require: false
gem "image_processing"

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
gem "csv"
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
  gem "lookbook"

  gem "actual_db_schema"
  gem "amazing_print"
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
  gem "flatware-rspec", require: false
  gem "parallel_tests"
  gem "turbo_tests", github: "inkstak/turbo_tests", branch: "feature-handle_fuubar"
end

group :development do
  gem "annotaterb"
  gem "bundle_update_interactive"
  gem "localhost"
  gem "rack-mini-profiler"
  gem "web-console"

  # Linting
  gem "rubocop",             require: false
  gem "rubocop-capybara",    require: false
  gem "rubocop-factory_bot", require: false
  gem "rubocop-performance", require: false
  gem "rubocop-rails",       require: false
  gem "rubocop-rake",        require: false
  gem "rubocop-rspec",       require: false
  gem "rubocop-rspec_rails", require: false

  # Tests & lint automation
  gem "guard"
  gem "guard-brakeman", require: false
  gem "guard-rspec",    require: false
  gem "guard-rubocop",  require: false

  # Audit dependencies and common vulnerabilities
  gem "brakeman"
  gem "bundler-audit"

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
  gem "moarspec"
  gem "rspec-collection_matchers"
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
