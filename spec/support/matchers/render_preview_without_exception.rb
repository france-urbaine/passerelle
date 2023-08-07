# frozen_string_literal: true

module Matchers
  module RenderPreviewWithoutException
    extend RSpec::Matchers::DSL

    matcher :render_preview_without_exception do |expected_method|
      match do |actual|
        if actual.class <= ViewComponent::Preview
          render_preview(expected_method, from: actual.class)
          true
        else
          pending "TODO: handle Lookbook::Preview subclasses"
          false
        end
      end
    end
  end
end
