# frozen_string_literal: true

module Layout
  # @display frame "content"
  #
  class DatatableComponentPreview < ViewComponent::Preview
    # @label Default
    #
    def default
      render_with_template(locals: { records: })
    end

    # @label Without records
    #
    def without_records
      render_with_template(locals: { records: records.none })
    end

    # @label With grouped columns
    #
    def with_irregular_columns
      render_with_template(locals: { records: })
    end

    # @label With checkboxes
    #
    def with_checkboxes
      render_with_template(locals: { records: })
    end

    # @label With actions
    #
    def with_actions
      render_with_template(locals: { records: })
    end

    # @label With sortable columns
    #
    def with_sortable_columns
      render_with_template(locals: { records: records.unscope(:order).preload(:epci) })
    end

    # @label With search
    #
    def with_search
      render_with_template(locals: { records: })
    end

    # @label With pagination
    #
    def with_pagination
      render_with_template(locals: { records:, pagy: })
    end

    # @label With selection bar
    #
    def with_selection_bar
      render_with_template(locals: { records:, pagy: })
    end

    private

    def records
      ::Commune.limit(10).order(:code_insee)
    end

    def pagy
      Pagy.new(count: 125, page: 3, items: 20)
    end
  end
end
