# frozen_string_literal: true

module DocumentationExamples
  class Component < ApplicationViewComponent
    def initialize(resource, method)
      @resource = resource
      @method   = method
      super()
    end

    def examples
      @examples ||= Apipie.recorded_examples["#{@resource[:id]}##{@method[:name]}"].select do |example|
        example["show_in_doc"] != 0 &&
          (example["versions"].nil? || example["versions"].include?(@resource[:version]))
      end
    end

    def render_http_code_badge(http_code)
      css_class = case http_code
                  when 200..299
                    "badge badge--green"
                  when 300..399
                    "badge badge--violet"
                  when 400..499
                    "badge badge--pink"
                  when 500..599
                    "badge badge--red"
                  else
                    "badge badge--blue"
                  end

      tag.code(class: css_class) do
        http_code.to_s
      end
    end

    def full_path(example)
      example[:query].present? ? "#{path}?#{example['query']}" : example["path"]
    end
  end
end
