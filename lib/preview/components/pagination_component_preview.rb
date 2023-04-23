# frozen_string_literal: true

class PaginationComponentPreview < ViewComponent::Preview
  # @!group Basic
  #
  # @label Basic usage
  #
  def basic
    render_with_template(locals: { pagy: })
  end

  # @label Buttons targeting a turbo-frame
  #
  def with_turbo_frame
    render_with_template(locals: { pagy: })
  end
  #
  # @!endgroup

  private

  def pagy
    Pagy.new(count: 125, page: 3, items: 20)
  end
end
