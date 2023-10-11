# frozen_string_literal: true

module DocumentationExamples
  class Component < ApplicationViewComponent
    def initialize(resource, method)
      @resource = resource
      @method   = method
      super()
    end

    def examples
      @examples ||= (Apipie.recorded_examples["#{@resource[:id]}##{@method[:name]}"] || []).select do |example|
        example["show_in_doc"] != 0 &&
          (example["versions"].nil? || example["versions"].include?(@resource[:version]))
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
