# frozen_string_literal: true

source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.2.2"

# Core gems
gem "bootsnap", require: false
gem "puma", "~> 6.0"
gem "rails", "~> 7.0.2", ">= 7.0.2.3"

# Database
gem "fx"
gem "pg", "~> 1.1"
gem "redis", "~> 5.0"

# Models
gem "devise"
# https://github.com/tinfoil/devise-two-factor/pull/240
gem "devise-two-factor", github: "inkstak/devise-two-factor", branch: "bugfix-insert_two_factor_authenticatable_on_top"
gem "discard"

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

group :development, :test do
  gem "lookbook", ">= 2.0.0"

  # FIXME: waiting for this PR to be released
  # The gem can be removed from the Gemfile after release because
  # its already a dependency of lookbook
  # https://github.com/threedaymonk/htmlbeautifier/pull/74
  gem "htmlbeautifier", github: "inkstak/htmlbeautifier", branch: "allow_custom_elements"

  gem "awesome_print"

  # https://github.com/mattbrictson/bundleup/pull/214
  gem "bundleup", github: "inkstak/bundleup", branch: "return_cli_report"
  gem "byebug"
  gem "dead_end"
  gem "debug", platforms: %i[mri mingw x64_mingw]
  gem "dotenv"

  gem "factory_bot"
  gem "factory_bot-awesome_linter"
  gem "factory_bot_rails"
  gem "parallel_tests"
  gem "rspec"
  gem "rspec-rails"
end

group :development do
  gem "annotate"
  gem "foreman"
  gem "rack-mini-profiler"
  gem "web-console"

  # Linting
  gem "rubocop",             require: false
  gem "rubocop-performance", require: false
  gem "rubocop-rails",       require: false
  gem "rubocop-rake",        require: false
  gem "rubocop-rspec",       require: false

  # Tests & lint automation
  gem "guard"
  gem "guard-brakeman", require: false
  gem "guard-rspec",    require: false
  gem "guard-rubocop",  require: false

  gem "brakeman"
  gem "bundler-audit"

  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"
end

group :test do
  gem "database_cleaner-active_record"
  gem "simplecov", require: false
  gem "timecop"
  gem "webmock"

  # RSpec extensions
  gem "fuubar"
  gem "rspec-collection_matchers"
  gem "rspec-github", require: false
  gem "saharspec"
  gem "shoulda-matchers"
  gem "super_diff"

  # System tests
  gem "capybara"
  gem "cuprite"

  # Analyse and improve test performances
  gem "test-prof"
end
