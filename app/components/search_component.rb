# frozen_string_literal: true

class SearchComponent < ViewComponent::Base
  attr_reader :label, :turbo_frame

  def initialize(label: "Rechercher", turbo_frame: "_top")
    @label       = label
    @turbo_frame = turbo_frame
    super()
  end
end
