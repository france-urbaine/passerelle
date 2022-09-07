# frozen_string_literal: true

class CheckBoxesCollectionComponent < ViewComponent::Base
  attr_reader :object_name, :method, :collection, :other_args

  def initialize(object_name, method, collection, *args)
    @object_name = object_name
    @method      = method
    @collection  = collection
    @other_args  = args
    super()
  end
end
