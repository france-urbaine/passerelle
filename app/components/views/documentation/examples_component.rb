# frozen_string_literal: true

module Views
  module Documentation
    class ExamplesComponent < ApplicationViewComponent
      def initialize(resource_name, method_name, version = nil)
        @resource_name = resource_name
        @method_name   = method_name
        @version       = version
        super()
      end

      def examples
        @examples ||=
          Apipie.recorded_examples.fetch("#{@resource_name}##{@method_name}", []).select do |example|
            (@version.nil? || (example["versions"].nil? || example["versions"].include?(@version)))
          end
      end

      def render_http_code_badge(http_code)
        css_class = "http-code http-code--#{http_code.floor(-2)}"

        tag.code(class: css_class) do
          http_code.to_s
        end
      end

      def full_path(example)
        example[:query].present? ? "#{path}?#{example['query']}" : example["path"]
      end
    end
  end
end
