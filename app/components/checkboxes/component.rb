# frozen_string_literal: true

module Checkboxes
  class Component < ApplicationViewComponent
    def initialize(object_name, method, collection, *args)
      @object_name = object_name
      @method      = method
      @collection  = collection
      @other_args  = args
      super()
    end
  end
end
