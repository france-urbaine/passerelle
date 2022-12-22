# frozen_string_literal: true

module ComponentsHelper
  def dialog_component(&)
    render(DialogComponent.new, &)
  end

  def search_component(...)
    render(SearchComponent.new(...))
  end

  def index_options_component(...)
    render(IndexOptionsComponent.new(...))
  end

  def order_column(...)
    render(OrderColumnComponent.new(...))
  end

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
