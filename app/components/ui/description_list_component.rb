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
      renders_many :actions, "ActionSlot"
      renders_one  :reference

      def initialize(record, label, **options)
        @record  = record
        @label   = label
        @options = options
        super()
      end

      def label
        if @record.class.respond_to?(:human_attribute_name)
          @record.class.human_attribute_name(@label, default: @label)
        else
          @label
        end
      end

      def row_html_attributes
        options = @options.dup

        css_class = %w[description-list__row]
        css_class << "description-list__row--with-actions" if actions?
        css_class << "description-list__row--with-reference" if reference?
        css_class << options[:class]

        options[:class] = css_class.join(" ").squish
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
