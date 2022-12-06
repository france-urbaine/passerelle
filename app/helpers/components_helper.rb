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

  def svg_icon(...)
    render(SVG::IconComponent.new(...))
  end

  def svg_use(...)
    render(SVG::UseComponent.new(...))
  end
end
