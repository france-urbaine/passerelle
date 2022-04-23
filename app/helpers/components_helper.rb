# frozen_string_literal: true

module ComponentsHelper
  def dialog(**options, &)
    render(DialogComponent.new(**options), &)
  end

  def datatable_search_form(...)
    render(Datatable::SearchFormComponent.new(...))
  end

  def datatable_header_pagination(...)
    render(Datatable::PaginationHeaderComponent.new(...))
  end

  def datatable_footer_pagination(...)
    render(Datatable::PaginationFooterComponent.new(...))
  end

  def order_column(...)
    render(Datatable::OrderColumnComponent.new(...))
  end

  def svg_icon(name, title = nil, height: 20, width: 20, **options)
    options[:"aria-hidden"] = true if title.nil?

    tag.svg(height:, width:, **options) do
      concat(tag.title(title)) if title
      concat(tag.use(href: "##{name}"))
    end
  end
end
