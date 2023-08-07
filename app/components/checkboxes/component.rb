# frozen_string_literal: true

module Checkboxes
  class Component < ApplicationViewComponent
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
          %i[id to_s]
        end
      in [Array, *]
        %i[first second]
      else
        %i[to_s to_s]
      end
    end
  end
end
