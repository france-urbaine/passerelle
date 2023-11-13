# frozen_string_literal: true

module UI
  class DescriptionListComponent < ApplicationViewComponent
    define_component_helper :description_list_component

    renders_many :attributes, lambda { |*args, **options|
      Attribute.new(@record, *args, **options)
    }

    attr_reader :record

    def initialize(record = nil)
      @record = record
      super()
    end

    def before_render
      # Eager loading all attributes
      content
      attributes.each(&:to_s)
    end

    class Attribute < ApplicationViewComponent
      renders_many :actions, ::UI::ButtonComponent
      renders_one  :reference

      def initialize(record, label, **options)
        @record  = record
        @label   = label
        @options = options
        super()
      end

      def label
        if @record && @label && @record.respond_to?(@label)
          @record.class.human_attribute_name(@label)
        else
          @label
        end
      end

      def row_html_attributes
        options         = @options.dup
        options[:class] = Array.wrap(options[:class])
        options[:class].unshift("description-list__row")
        options[:class].unshift("description-list__row--with-actions") if actions?
        options[:class].unshift("description-list__row--with-reference") if reference?
        options
      end

      def value
        return @value if defined?(@value)

        @value =
          if !content? && @record && @record.respond_to?(@label)
            @record.public_send(@label)
          else
            content
          end
      end

      def value?
        value.present?
      end

      def call
        content
      end
    end
  end
end
