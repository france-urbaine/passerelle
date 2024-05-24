# frozen_string_literal: true

module UI
  module Form
    module Autocomplete
      class Component < ApplicationViewComponent
        define_component_helper :autocomplete_component

        renders_one :label,        ->(*args, **options) { Label.new(self, *args, **options) }
        renders_one :search_field, ->(*args, **options) { SearchField.new(self, *args, **options) }
        renders_one :hidden_field, ->(*args, **options) { HiddenField.new(self, *args, **options) }

        renders_many :errors
        renders_one  :hint

        renders_many :noscripts, "UI::Noscript::Component"

        attr_reader :object_name, :method_name, :object, :placeholder, :options

        def initialize(object_name, method_name, url:, object: nil, placeholder: nil, **options)
          @object_name     = object_name
          @method_name     = method_name
          @url             = url
          @object          = object
          @placeholder     = placeholder
          @options         = options.extract!(:min_length, :submit_on_enter, :delay)
          @html_attributes = parse_html_attributes(**options)

          super()
        end

        def before_render
          with_search_field unless search_field
          with_hidden_field unless hidden_field
        end

        def html_attributes
          attributes = reverse_merge_attributes(@html_attributes, {
            class:       "autocomplete",
            data: {
              controller:                  "autocomplete",
              autocomplete_url_value:      @url,
              autocomplete_selected_class: "datalist__option--active",
              **autocomplete_options
            }
          })

          attributes = reverse_merge_attributes(attributes, { class: "hidden" }) if noscripts?
          attributes
        end

        def autocomplete_options
          @options.each_with_object({}) do |(key, value), hash|
            case key
            when :min_length, :delay
              hash[:"autocomplete_#{key}_value"] = value
            else
              hash[:"autocomplete_#{key}"] = value
            end
          end
        end

        class Label < ApplicationViewComponent
          def initialize(parent, label = nil, **options)
            @parent           = parent
            @object_name      = parent.object_name
            @method_name      = parent.method_name
            @label            = label
            @options          = options
            @options[:object] = parent.object
            super()
          end

          def call
            helpers.label(@object_name, @method_name, @label, @options)
          end
        end

        class SearchField < ApplicationViewComponent
          def initialize(parent, **)
            @parent          = parent
            @object_name     = parent.object_name
            @method_name     = parent.method_name
            @object          = parent.object
            @html_attributes = parse_html_attributes(**)
            super()
          end

          def call
            helpers.search_field(@object_name, @method_name, html_attributes)
          end

          def html_attributes
            attributes = reverse_merge_attributes(@html_attributes, {
              placeholder: @parent.placeholder,
              data:       { autocomplete_target: "input" }
            })

            if @parent.object
              attributes[:object] = @parent.object
              attributes[:value] ||= value
            end

            attributes
          end

          def value
            return unless @parent.object.respond_to?(@method_name)

            associated_object = @parent.object.public_send(@method_name)

            if associated_object.respond_to?(:name)
              associated_object.name
            else
              associated_object.to_s
            end
          end
        end

        class HiddenField < ApplicationViewComponent
          def initialize(parent, method_name = nil, **)
            @parent          = parent
            @object_name     = parent.object_name
            @method_name     = method_name || :"#{parent.method_name}_id"
            @html_attributes = parse_html_attributes(**)
            super()
          end

          def call
            helpers.hidden_field(@object_name, @method_name, html_attributes)
          end

          def html_attributes
            attributes = reverse_merge_attributes(@html_attributes, {
              data: { autocomplete_target: "hidden" }
            })

            attributes[:allow_method_names_outside_object] = true
            attributes[:object] = @parent.object if @parent.object
            attributes[:value]  = attributes[:value].to_json if attributes[:value].is_a?(Hash)
            attributes
          end
        end
      end
    end
  end
end
