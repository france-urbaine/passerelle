# frozen_string_literal: true

module UI
  class AttributesListComponent < ApplicationViewComponent
    renders_many :attributes, "AttributeRow"

    def initialize(record= nil, **options)
      @record  = record
      @options = options
      super()
    end

    def record
      @record
    end

    class AttributeRow < ApplicationViewComponent
      renders_many :actions, ::UI::ButtonComponent

      def initialize(label, **options)
        @label     = label
        @css_class = nil
      end

      def label
        @label
      end

      def css_class
        @css_class
      end

      def before_render
        @css_class= "flex justify-between" if self.actions.any?
      end

      def call
        content
      end
    end
  end
end
