# frozen_string_literal: true

Rails.application.configure do
  config.view_component.preview_paths << Rails.root.join("spec/components/previews")
  config.view_component.default_preview_layout = "component_preview"
  config.view_component.capture_compatibility_patch_enabled = true

  if ENV.fetch("INSTRUMENT_VIEW_COMPONENT", "false") == "true"
    # ViewComponent instrumentation could be very noisy, especially with Lookbook
    # That's why it isn't active by default.
    #
    config.view_component.instrumentation_enabled = true
    config.view_component.use_deprecated_instrumentation_name = false
  end

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
