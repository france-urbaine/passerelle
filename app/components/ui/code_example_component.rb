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

    class CopyableCodeComponent < ApplicationViewComponent
      define_component_helper :copyable_code_component

      def initialize(value)
        @value = value
        super()
      end

      def value
        sanitize(@value.to_s)
      end
    end
  end
end
