# frozen_string_literal: true

module UI
  class ContentFlowComponent < ApplicationViewComponent
    renders_many :sections, "Section"

    def before_render
      # Eager loading all sections
      content
      sections.each(&:to_s)
    end

    class Section < ApplicationViewComponent
      renders_one :header, "Header"

      def initialize(**options)
        @options = options
        super()
      end

      def separator?
        @options[:separator]
      end

      def call
        content
      end

      class Header < ApplicationViewComponent
        renders_many :actions

        def call
          content
        end
      end
    end
  end
end
