# frozen_string_literal: true

source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.1.1"

# Core gems
gem "bootsnap", require: false
gem "puma", "~> 5.0"
gem "rails", "~> 7.0.2", ">= 7.0.2.3"

# Database
gem "pg", "~> 1.1"
gem "redis", "~> 4.0"

# Models
gem "devise"
gem "discard"

# Controllers
gem "responders"

# Assets
gem "cssbundling-rails"
gem "importmap-rails"
gem "sprockets-rails"
gem "stimulus-rails"
gem "turbo-rails"

# Views
gem "jbuilder"
gem "rails-i18n"
gem "slim"
gem "view_component"

# Import utilities
gem "roo"
gem "rubyzip"

# Windows compatibility
gem "tzinfo-data", platforms: %i[mingw mswin x64_mingw jruby]

group :development, :test do
  gem "awesome_print"
  gem "dead_end"
  gem "debug", platforms: %i[mri mingw x64_mingw]
  gem "dotenv"

  gem "factory_bot"
  gem "factory_bot-awesome_linter"
  gem "factory_bot_rails"
  gem "faker"
  gem "parallel_tests"
  gem "rspec"
  gem "rspec-rails"
end

group :development do
  gem "annotate"
  gem "foreman"
  gem "rack-mini-profiler"
  gem "web-console"

  gem "rubocop",             require: false
  gem "rubocop-performance", require: false
  gem "rubocop-rails",       require: false
  gem "rubocop-rspec",       require: false

  gem "guard"
  gem "guard-rspec",   require: false
  gem "guard-rubocop", require: false

  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"
end

group :test do
  gem "capybara"
  gem "rspec-collection_matchers"
  gem "selenium-webdriver"
  gem "shoulda-matchers"
  gem "simplecov"
  gem "webdrivers"
  gem "webmock"
end
