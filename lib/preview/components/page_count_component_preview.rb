# frozen_string_literal: true

class PageCountComponentPreview < ViewComponent::Preview
  # @!group Basic
  #
  # @label Basic usage
  #
  def basic
    render_with_template(locals: { pagy: })
  end

  # @label With countable resource
  #
  def with_countable_resource
    render_with_template(locals: { pagy: })
  end

  # @label With irregular inflections
  #
  def with_inflections
    render_with_template(locals: { pagy: })
  end
  #
  # @!endgroup

  private

  def pagy
    Pagy.new(count: 125, page: 3, items: 20)
  end
end
