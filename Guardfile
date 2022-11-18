# frozen_string_literal: true

all_on_start    = ENV.fetch("ALL_ON_START", nil) == "true"
parallel_rspec  = ENV.fetch("PARALLEL", nil) == "true"

require_relative "./lib/guard/run"
Guard::FactoryBot = Class.new(Guard::Run)

Guard::UI.info "No guard called on start: use ALL_ON_START=true next time" unless all_on_start

factory_bot_options = { all_on_start:, cmd: "bundle exec bin/rails factory_bot:lint RAILS_ENV='test'" }
rspec_options       = { all_on_start:, cmd: "bundle exec rspec" }
rubocop_options     = { all_on_start:, cli: %w[--display-cop-names --server] }

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
    watch("spec/spec_helper.rb") { "spec" }
    watch(%r{^spec/.+_spec\.rb$})
    watch(%r{^app/(.+)\.rb$}) { |m| "spec/#{m[1]}_spec.rb" }
  end

  guard :rubocop, rubocop_options do
    watch(/.+\.rb$/)
    watch(%r{(?:.+/)?\.rubocop(?:_todo)?\.yml$}) { |m| File.dirname(m[0]) }
  end
end
