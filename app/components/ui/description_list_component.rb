# frozen_string_literal: true

module UI
  class DescriptionListComponent < ApplicationViewComponent
    renders_many :attributes, "DescriptionListAttribute"

    attr_reader :record

    def initialize(record = nil, **options)
      @record  = record
      @options = options
      super()
    end

    def before_render
      # Eager loading all attributes
      content
      attributes.each(&:to_s)
    end

    class DescriptionListAttribute < ApplicationViewComponent
      renders_many :actions, ::UI::ButtonComponent
      renders_one  :reference

      attr_reader :label

      def initialize(label, **options)
        @label   = label
        @options = options
        super()
      end

      def row_html_attributes
        options         = @options.dup
        options[:class] = Array.wrap(options[:class])
        options[:class].unshift("description-list__row")
        options[:class].unshift("description-list__row--with-actions") if actions?
        options[:class].unshift("description-list__row--with-reference") if reference?
        options
      end

      def call
        content
      end
    end
  end
end
