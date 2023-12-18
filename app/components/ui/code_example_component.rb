# frozen_string_literal: true

module UI
  class CodeExampleComponent < ApplicationViewComponent
    define_component_helper :code_example_component

    renders_many :languages, "Language"

    def initialize(language = nil, copyable: false)
      @language = language
      @copyable = copyable
      super()
    end

    def before_render
      # Eager loading all languages
      content
      languages.each(&:to_s)
    end

    def copyable?
      @copyable
    end

    def copyable_content
      if languages?
        languages.map(&:copyable_content).join("\n\n")
      else
        content
      end
    end

    def copyable_button(content)
      tag.button(
        class: %w[icon-button code-example__copy-button],
        data: {
          controller: "copy-text toggle",
          action:     "click->copy-text#copy click->toggle#toggle",
          "copy-text-source-value"    => sanitize(content.to_s),
          "toggle-revert-delay-param" => 2000
        }
      ) do
        concat icon_component("clipboard-document-list", "Copier le texte", data: { toggle_target: "item" })
        concat icon_component("check", "Texte copié", data: { toggle_target: "item" }, hidden: true)
      end
    end

    def highlight(content, language)
      data = { controller: "highlight", highlight_language_value: language } if language

      if language == :command
        data[:highlight_language_value] = "shell"
        content = add_command_line_prompt(content)
      end

      tag.span(data:) do
        content
      end
    end

    def add_command_line_prompt(content)
      return "" if content.blank?

      lines  = content.split("\n")
      output = []

      output << "$ #{lines[0]}"

      lines[1..].each do |line|
        output << "  #{line}"
      end

      output.join("\n")
    end

    class Language < ApplicationViewComponent
      attr_reader :language

      def initialize(language = nil, copyable: false)
        @language = language
        @copyable = copyable
        super()
      end

      def call
        content
      end

      def copyable?
        @copyable
      end

      def copyable_content
        content
      end
    end
  end
end
