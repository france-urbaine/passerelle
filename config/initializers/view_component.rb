# frozen_string_literal: true

Rails.application.configure do
  # FYI: We'd better have to use a String instead of a Pathname
  # otherwise it may not be able to eager load the directory
  #
  config.view_component.preview_paths << Rails.root.join("app/components").to_s
  config.view_component.preview_paths << Rails.root.join("spec/components/previews").to_s

  config.view_component.default_preview_layout = "component_preview"
  config.view_component.capture_compatibility_patch_enabled = true

  # ViewComponent instrumentation could be very noisy, especially with Lookbook
  # That's why it isn't active by default.
  #
  if ENV.fetch("INSTRUMENT_VIEW_COMPONENT", "false") == "true"
    config.view_component.instrumentation_enabled = true
    config.view_component.use_deprecated_instrumentation_name = false
  end

  if defined?(Lookbook)
    config.lookbook.project_name = "Passerelle"

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

ActiveSupport.on_load(:view_component) do
  # Extend your preview controller to support authentication and other
  # application-specific stuff
  #
  # Rails.application.config.to_prepare do
  #   ViewComponentsController.class_eval do
  #     include Authenticated
  #   end
  # end

  # Make it possible to store previews in sidecar folders
  # See https://github.com/palkan/view_component-contrib#organizing-components-or-sidecar-pattern-extended
  ViewComponent::Preview.extend ViewComponentContrib::Preview::Sidecarable

  # Enable `self.abstract_class = true` to exclude previews from the list
  ViewComponent::Preview.extend ViewComponentContrib::Preview::Abstract
end
