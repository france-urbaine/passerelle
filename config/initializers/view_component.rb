# frozen_string_literal: true

Rails.application.configure do
  config.view_component.preview_paths << Rails.root.join("app/components")
  config.view_component.default_preview_layout = "component_preview"
  config.view_component.capture_compatibility_patch_enabled = true

  if defined?(Lookbook)
    config.lookbook.project_name = "FiscaHub"

    HtmlBeautifier::HtmlParser.block_elements << "a"
    HtmlBeautifier::HtmlParser.block_elements << "button"
    HtmlBeautifier::HtmlParser.block_elements << "svg"
    HtmlBeautifier::HtmlParser.block_elements << "title"
    HtmlBeautifier::HtmlParser.block_elements << "label"
    HtmlBeautifier::HtmlParser.block_elements << "span"
    HtmlBeautifier::HtmlParser.block_elements << "main"
    HtmlBeautifier::HtmlParser.block_elements << "turbo-frame"
    HtmlBeautifier::HtmlParser.block_elements << "colgroup"
  end
end
