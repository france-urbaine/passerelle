# frozen_string_literal: true

Rails.application.configure do
  config.view_component.preview_paths << Rails.root.join("spec/components/previews")
  config.view_component.default_preview_layout = "component_preview"

  config.lookbook.project_name = "FiscaHub" if defined?(Lookbook)
end
