# frozen_string_literal: true

module Layout
  # @display frame "content"
  #
  class ContentLayoutComponentPreview < ViewComponent::Preview
    # @label Default
    def default; end

    # @label With icons
    def with_icons; end

    # @label With actions
    def with_actions; end

    # @!group With grid
    # --------------------------------------------------------------------------
    #
    # @label With default grid (2 columns)
    def with_grid; end

    # @label With more columns (and responsive breakpoints)
    def with_grid_more_columns; end
    #
    # @!endgroup

    # @!group With simpler DSL
    # --------------------------------------------------------------------------
    #
    # @label Layout with simpler DSL (1 single section)
    def with_simpler_dsl; end

    # @label Grid with simpler DSL (1 single section in columns)
    def with_simpler_dsl_grid; end
    #
    # @!endgroup

    # --------------------------------------------------------------------------
    # @label With components
    def with_components; end
  end
end
