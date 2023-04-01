# frozen_string_literal: true

module SVGHelper
  def svg_icon(icon, title = nil, **options)
    if title
      options[:title] = title
      options[:aria] ||= true
    else
      options[:aria_hidden] = true
    end

    inline_svg_tag("#{icon}.svg", **options)
      .strip
      .gsub(%(aria-hidden="true"), "aria-hidden")
      .gsub(%r{></(path|circle|rect)>}, "/>")
      .html_safe # rubocop:disable Rails/OutputSafety
  end
end
