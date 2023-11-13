# frozen_string_literal: true

module UI
  class CodeExampleComponent < ApplicationViewComponent
    define_component_helper :code_example_component

    renders_many :languages, "Language"

    def initialize(language = nil)
      @language = language
      super()
    end

    class Language < ApplicationViewComponent
      attr_reader :language

      def initialize(language)
        @language = language
        super()
      end

      def call
        content
      end
    end
  end
end
