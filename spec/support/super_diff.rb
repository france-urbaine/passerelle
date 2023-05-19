# frozen_string_literal: true

return if ENV.fetch("SUPER_DIFF", nil) == "false"

class MailMessageInspector < SuperDiff::ObjectInspection::InspectionTreeBuilders::Base
  def self.applies_to?(value)
    value.is_a?(::Mail::Message)
  end

  def call
    SuperDiff::ObjectInspection::InspectionTree.new do
      add_text(&:inspect)
    end
  end
end

SuperDiff.configure do |config|
  config.diff_elision_enabled = true
  config.add_extra_inspection_tree_builder_classes(MailMessageInspector)
end

require "super_diff/rspec"
require "super_diff/rails"
