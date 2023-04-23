# frozen_string_literal: true

class InflectionsComponent < ViewComponent::Base
  attr_reader :singular, :plural, :feminine
  alias feminine? feminine

  def initialize(word = nil, singular: nil, plural: nil, feminine: false)
    raise ArgumentError, "use argument or keyword arguments, not both" if word && singular

    @singular = word || singular
    @plural   = plural || @singular.pluralize
    @feminine = feminine
    super()
  end
end
