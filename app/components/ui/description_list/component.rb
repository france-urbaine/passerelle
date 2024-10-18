# frozen_string_literal: true

module UI
  module DescriptionList
    class Component < ApplicationViewComponent
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

        def initialize(record, label, **)
          @record          = record
          @label           = label
          @html_attributes = parse_html_attributes(**)
          super()
        end

        def label
          if @record.class.respond_to?(:human_attribute_name)
            @record.class.human_attribute_name(@label, default: @label)
          else
            @label
          end
        end

        def html_attributes
          merge_attributes(@html_attributes, {
            class: [
              "description-list__row",
              ("description-list__row--with-actions" if actions?),
              ("description-list__row--with-reference" if reference?)
            ]
          })
        end

        def value
          return @value if defined?(@value)

          @value =
            if content?
              content
            elsif @record.nil?
              nil
            elsif @record.respond_to?(@label)
              @record.public_send(@label)
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
end
