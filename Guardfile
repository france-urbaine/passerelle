# frozen_string_literal: true

all_on_start    = ENV["ALL_ON_START"] != "false"
parallel_rspec  = ENV["PARALLEL"] == "true"
rspec_options   = { all_on_start:, cmd: "bundle exec rspec" }
rubocop_options = { all_on_start:, cli: %w[--display-cop-names] }

if parallel_rspec
  rspec_options[:run_all] = {
    cmd: "bundle exec parallel_rspec -o '",
    cmd_additional_args: "'"
  }
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
