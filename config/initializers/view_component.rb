# frozen_string_literal: true

Rails.application.configure do
  config.view_component.preview_paths << Rails.root.join("spec/components/previews")
  config.view_component.default_preview_layout = "component_preview"

  if defined?(Lookbook)
    config.lookbook.project_name = "FiscaHub"

    HtmlBeautifier::HtmlParser.block_elements << "main"
    HtmlBeautifier::HtmlParser.block_elements << "turbo-frame"
    HtmlBeautifier::HtmlParser.block_elements << "colgroup"
  end
end
