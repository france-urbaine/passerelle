# frozen_string_literal: true

module ComponentsHelper
  def dialog(**options, &)
    render(DialogComponent.new(**options), &)
  end

  def search(...)
    render(SearchComponent.new(...))
  end

  def index_options(...)
    render(IndexOptionsComponent.new(...))
  end

  def order_column(...)
    render(OrderColumnComponent.new(...))
  end

  def svg_icon(name, title = nil, **options)
    options[:"aria-hidden"] = true if title.nil?

    tag.svg(**options) do
      concat(tag.title(title)) if title
      concat(tag.use(href: "##{name}"))
    end
  end
end
