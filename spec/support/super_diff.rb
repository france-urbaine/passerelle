# frozen_string_literal: true

return if ENV.fetch("SUPER_DIFF", nil) == "false"

SuperDiff.configure do |config|
  config.diff_elision_enabled = true
end

require "super_diff/rspec"
require "super_diff/rails"
