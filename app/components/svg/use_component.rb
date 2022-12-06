# frozen_string_literal: true

module SVG
  class UseComponent < ViewComponent::Base
    def initialize(id, title = nil, **attributes)
      @id = id
      @title = title
      @attributes = attributes
      super()
    end

    def svg_attributes
      @svg_attributes ||= begin
        attributes = @attributes
        attributes[:aria_hidden] = true if @title.nil?
        attributes
      end
    end
  end
end
