# frozen_string_literal: true

module Matchers
  module RenderPreviewWithoutException
    extend RSpec::Matchers::DSL

    matcher :render_preview_without_exception do |expected_method|
      match do |actual|
        render_preview(expected_method, from: actual.class)
        true
      end
    end
  end
end
