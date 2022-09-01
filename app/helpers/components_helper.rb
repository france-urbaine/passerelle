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

  def svg_icon(name, title = nil, **options)
    options[:"aria-hidden"] = true if title.nil?

    tag.svg(**options) do
      concat(tag.title(title)) if title
      concat(tag.use(href: "##{name}"))
    end
  end
end
