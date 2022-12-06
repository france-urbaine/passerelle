# frozen_string_literal: true

module SVG
  class IconComponent < ViewComponent::Base
    def initialize(id, title = nil, **attributes)
      @id = id
      @title = title
      @attributes = attributes
      super()
    end

    def svg_attributes
      @svg_attributes ||= begin
        attributes = svg_node.attributes
        attributes.merge!(@attributes)
        attributes[:aria] ||= {}
        attributes[:aria][:hidden] = true if @title.nil?
        attributes
      end
    end

    def raw_svg
      raise "invalid SVG id: #{@id}" unless @id.match?(/^[a-z-]+$/)

      @raw_svg ||= Rails.root.join("app/assets/icons", "#{@id}.svg").read
    end

    def svg_node
      @svg_node ||= Nokogiri::HTML::DocumentFragment.parse(raw_svg).at_css("svg")
    end
  end
end
