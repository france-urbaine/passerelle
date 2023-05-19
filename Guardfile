# frozen_string_literal: true

all_on_start    = ENV.fetch("ALL_ON_START", nil) == "true"
parallel_rspec  = ENV.fetch("PARALLEL", nil) == "true"

require_relative "./lib/guard/run"
Guard::FactoryBot = Class.new(Guard::Run)

unless ENV["SKIP_ALL_ON_START_WARNING"] || all_on_start
  Guard::UI.info "No guard called on start: use ALL_ON_START=true next time"
end

factory_bot_options = { all_on_start:, cmd: "bundle exec bin/rails factory_bot:lint RAILS_ENV='test'" }
rspec_options       = { all_on_start:, cmd: "bundle exec rspec --no-profile" }
rubocop_options     = { all_on_start:, cli: %w[--display-cop-names --server] }
brakeman_options    = { run_on_start: all_on_start, quiet: true }

if parallel_rspec
  rspec_options[:run_all] = {
    cmd: "bundle exec parallel_rspec -o '",
    cmd_additional_args: "'"
  }
end

group :red_green_refactor, halt_on_fail: true do
  guard :factory_bot, factory_bot_options do
    watch(%r{^spec/factories/(.+)\.rb$})
  end

  guard :rspec, rspec_options do
    watch("config/routes.rb") { "spec/routing" }
    watch(%r{^spec/.+_spec\.rb$})
    watch(%r{^app/(.+)\.rb$})             { |m| "spec/#{m[1]}_spec.rb" }
    watch(%r{^app/controllers/(.+)\.rb$}) { |m| "spec/requests/#{m[1]}" }
  end

  guard :rubocop, rubocop_options do
    watch(/.+\.rb$/)
    watch(%r{(?:.+/)?\.rubocop(?:_todo)?\.yml$}) { |m| File.dirname(m[0]) }
  end

  guard :brakeman, brakeman_options do
    watch(%r{^app/.+\.(erb|haml|rhtml|rb)$})
    watch(%r{^config/.+\.rb$})
    watch(%r{^lib/.+\.rb$})
    watch("Gemfile")
  end
end
