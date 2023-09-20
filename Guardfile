# frozen_string_literal: true

# Setup guard using env variables
# - use ALL_ON_START to run all guards on startup
# - use PARALLEL to run rspec on multiple CPUs
#
all_on_start    = ENV.fetch("ALL_ON_START", nil) == "true"
parallel_rspec  = ENV.fetch("PARALLEL", nil) == "true"

# - use SKIP_ALL_ON_START_WARNING to avoid showing a warning on startup
#
unless ENV["SKIP_ALL_ON_START_WARNING"] || all_on_start
  Guard::UI.info "No guard called on start: use ALL_ON_START=true next time"
end

# Setup FactoryBot linter
#
require_relative "lib/guard/run"
Guard::FactoryBot = Class.new(Guard::Run)

# Prepare options of guard defined below
#
factory_bot_options = { all_on_start:, cmd: "bundle exec bin/rails factory_bot:lint RAILS_ENV='test'" }
rspec_options       = { all_on_start:, cmd: "bundle exec rspec --no-profile" }
rubocop_options     = { all_on_start:, cli: %w[--display-cop-names --server] }
erb_lint_options    = { all_on_start: }
brakeman_options    = { run_on_start: all_on_start, quiet: true }

if parallel_rspec
  rspec_options[:run_all] = {
    cmd: "bundle exec parallel_rspec -o '",
    cmd_additional_args: "'"
  }
end

# Uncomment and set this to only include directories you want to watch
# directories %w(app lib config test spec features) \
#  .select{|d| Dir.exists?(d) ? d : UI.warning("Directory #{d} does not exist")}
#
# Note: if you are using the `directories` clause above and you are not
# watching the project directory ('.'), then you will want to move
# the Guardfile to a watched dir and symlink it back, e.g.
#
#  $ mkdir config
#  $ mv Guardfile config/
#  $ ln -s config/Guardfile .
#
# and, you'll have to watch "config/Guardfile" instead of "Guardfile"
#

group :red_green_refactor, halt_on_fail: true do
  guard :factory_bot, factory_bot_options do
    watch(%r{^spec/factories/(.+)\.rb$})
  end

  guard :rspec, rspec_options do
    watch("config/routes.rb") { "spec/routing" }
    watch(%r{^spec/.+_spec\.rb$})

    watch(%r{^app/(.+)\.rb$}) do |m|
      "spec/#{m[1]}_spec.rb"
    end

    watch(%r{^app/controllers/(.+)_controller\.rb$}) do |m|
      Dir[File.join("spec/requests/#{m[1]}/*_spec.rb")]
    end
  end

  guard :rubocop, rubocop_options do
    watch("Gemfile")
    watch("Guardfile")
    watch(/.+\.rb$/)
    watch(%r{(?:.+/)?\.rubocop(?:_todo)?\.yml$}) { |m| File.dirname(m[0]) }
  end

  guard :erb_lint, erb_lint_options do
    watch(%r{^app/.+\.erb$})
    watch(%r{^spec/.+\.html$})

    # If we need to watch any *.html files in the future
    # we cannot just watch /.+\.html$/ because it may hang on coverage files.
    # Instead, we need to add watcher per folder.
  end

  guard :brakeman, brakeman_options do
    watch(%r{^app/.+\.(erb|haml|rhtml|rb)$})
    watch(%r{^config/.+\.rb$})
    watch(%r{^lib/.+\.rb$})
    watch("Gemfile")
  end
end
