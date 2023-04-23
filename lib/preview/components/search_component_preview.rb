# frozen_string_literal: true

class SearchComponentPreview < ViewComponent::Preview
  # @!group Default
  #
  # @label Basic search form
  #
  def basic; end

  # @label Search form with a defined label
  #
  def with_label; end

  # @label Search form targeting a turbo-frame
  #
  def with_turbo_frame; end
  #
  # @!endgroup
end
