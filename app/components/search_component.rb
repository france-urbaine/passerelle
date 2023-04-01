# frozen_string_literal: true

class SearchComponent < ViewComponent::Base
  attr_reader :label

  def initialize(label: "Rechercher")
    @label = label
    super()
  end
end
