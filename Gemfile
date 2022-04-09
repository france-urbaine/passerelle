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

# Windows compatibility
gem "tzinfo-data", platforms: %i[mingw mswin x64_mingw jruby]

group :development, :test do
  gem "awesome_print"
  gem "dead_end"
  gem "debug", platforms: %i[mri mingw x64_mingw]
end

group :development do
  gem "rack-mini-profiler"
  gem "web-console"

  gem "rubocop",             require: false
  gem "rubocop-performance", require: false
  gem "rubocop-rails",       require: false
  gem "rubocop-rspec",       require: false

  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"
end

group :test do
  gem "capybara"
  gem "selenium-webdriver"
  gem "webdrivers"
end
