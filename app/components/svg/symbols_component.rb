# frozen_string_literal: true

module SVG
  class SymbolsComponent < ViewComponent::Base
    def svgs
      @svgs ||= Rails.root.glob("app/assets/icons/*.svg").to_h do |path|
        [path.basename(".svg").to_s, path.read]
      end
    end

    def symbols
      @symbols ||= svgs.to_h do |name, raw_svg|
        document = Nokogiri::HTML::DocumentFragment.parse(raw_svg)

        svg = document.at_css("svg")
        svg.name = "symbol"
        svg.delete "xmlns"
        svg["id"] = "#{name}-icon"

        [name, document.to_html]
      end
    end
  end
end
