# frozen_string_literal: true

return unless ENV.fetch("SUPER_DIFF", nil) == "true"

SuperDiff.configure do |config|
  config.diff_elision_enabled = true
end

require "super_diff/rspec-rails"
