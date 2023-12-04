# frozen_string_literal: true

module UI
  class CodeExampleComponent < ApplicationViewComponent
    define_component_helper :code_example_component

    renders_many :languages, "Language"

    def initialize(language = nil, **options)
      @language = language
      @copyable = options[:copyable]
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
      return nil unless copyable?

      if languages?
        languages.map(&:copyable_content).join("\n\n")
      elsif @language == :shell
        self.class.filter_command_prompt(content)
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

    def self.filter_command_prompt(command)
      # Removing starting $ from command line
      command.gsub(/\A( )*\$( )*/, "")
    end

    class Language < ApplicationViewComponent
      attr_reader :language

      def initialize(language, **options)
        @language = language
        @copyable = options[:copyable]
        super()
      end

      def copyable?
        @copyable
      end

      def copyable_content
        if @language == :shell
          CodeExampleComponent.filter_command_prompt(content)
        else
          content
        end
      end

      def call
        content
      end
    end
  end
end
