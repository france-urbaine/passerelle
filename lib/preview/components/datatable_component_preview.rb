# frozen_string_literal: true

class DatatableComponentPreview < ViewComponent::Preview
  # @label Basic table
  #
  def basic
    render_with_template(locals: { records: records })
  end

  # @label Without data
  #
  def with_none
    render_with_template(locals: { records: records })
  end

  # @label With checkboxes
  #
  def with_selection
    render_with_template(locals: { records: records })
  end

  # @label With actions
  #
  def with_actions
    render_with_template(locals: { records: records })
  end

  # @label With sortable columns
  #
  def with_sortable_columns
    render_with_template(locals: { records: records.unscope(:order).preload(:epci) })
  end

  # @label With grouped column headers
  #
  def with_irregular_columns
    render_with_template(locals: { records: records })
  end

  private

  def records
    ::Commune.limit(10).order(:code_insee)
  end
end
