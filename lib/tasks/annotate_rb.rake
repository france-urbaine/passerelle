# frozen_string_literal: true

if Rails.env.development? && ENV["QUICK_MIGRATION_UPDATE"] != "true"
  require "annotate_rb"

  AnnotateRb::Core.load_rake_tasks
end
