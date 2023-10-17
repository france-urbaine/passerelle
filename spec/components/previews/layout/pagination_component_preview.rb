# frozen_string_literal: true

module Layout
  # @display frame "content"
  #
  class PaginationComponentPreview < ViewComponent::Preview
    # @!group Default
    # --------------------------------------------------------------------------
    #
    # @label Default
    #
    def default
      render_with_template(locals: { pagy: })
    end

    # @label With countable model
    #
    def with_countable_model
      render_with_template(locals: { pagy: })
    end

    # @label With countable word
    #
    def with_countable_word
      render_with_template(locals: { pagy: })
    end

    # @label With irregular inflections
    #
    def with_inflections
      render_with_template(locals: { pagy: })
    end

    # @label Buttons targeting a turbo-frame
    #
    def with_turbo_frame
      render_with_template(locals: { pagy: })
    end

    # @label With order options
    #
    def with_orders
      render_with_template(locals: { pagy: })
    end
    #
    # @!endgroup

    # @!group Buttons
    # --------------------------------------------------------------------------
    #
    # @label Default
    #
    def buttons_default
      render_with_template(locals: { pagy: })
    end

    # @label Buttons targeting a turbo-frame
    #
    def buttons_with_turbo_frame
      render_with_template(locals: { pagy: })
    end
    #
    # @!endgroup

    # @!group Counts
    # --------------------------------------------------------------------------
    #
    # @label Default
    #
    def counts_default
      render_with_template(locals: { pagy: })
    end

    # @label With countable model
    #
    def counts_with_countable_model
      render_with_template(locals: { pagy: })
    end

    # @label With countable word
    #
    def counts_with_countable_word
      render_with_template(locals: { pagy: })
    end

    # @label With irregular inflections
    #
    def counts_with_inflections
      render_with_template(locals: { pagy: })
    end
    #
    # @!endgroup

    # @!group Options
    # --------------------------------------------------------------------------
    #
    # @label Default
    #
    def options_default
      render_with_template(locals: { pagy: })
    end

    # @label With actions targeting a turbo-frame
    #
    def options_with_turbo_frame
      render_with_template(locals: { pagy: })
    end

    # @label With directions
    #
    def options_with_direction
      render_with_template(locals: { pagy: })
    end

    # @label With order options
    #
    def options_with_orders
      render_with_template(locals: { pagy: })
    end
    #
    # @!endgroup

    private

    def pagy
      Pagy.new(count: 125, page: 3, items: 20)
    end
  end
end
