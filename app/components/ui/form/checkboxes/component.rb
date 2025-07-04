# frozen_string_literal: true

module UI
  module Form
    module Checkboxes
      class Component < ApplicationViewComponent
        define_component_helper :checkboxes_component

        def initialize(object_name, method, collection, value_method: nil, text_method: nil, **options)
          @object_name  = object_name
          @method       = method
          @collection   = collection.to_a
          @value_method = value_method || default_input_methods[0]
          @text_method  = text_method || default_input_methods[1]
          @options      = options
          super()
        end

        def default_input_methods
          case @collection
          in [ApplicationRecord, *]
            if @collection.first.respond_to?(:name)
              %i[id name]
            else
              # :nocov:
              %i[id to_s]
              # :nocov:
            end
          in [Array, *]
            %i[first second]
          else
            %i[to_s to_s]
          end
        end

        def check_all_id
          "#{@object_name}_#{@method}_check_all"
        end

        def html_options
          reverse_merge_attributes(@options.fetch(:html_options, {}), {
            data: { selection_target: "checkbox" }
          })
        end
      end
    end
  end
end
