# frozen_string_literal: true

class SearchComponent < ViewComponent::Base
  attr_reader :label

  def initialize(label)
    @label = label
  end
end
