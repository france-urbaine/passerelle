# frozen_string_literal: true

# @display full_width true
#
class TemplateFrameComponentPreview < ViewComponent::Preview
  # @label Default usage
  #
  def default; end

  # @label With asynchronous loading
  #
  def with_async_content; end

  # @label With modal
  #
  def with_modal; end

  # @label With modal and asynchronous background
  #
  def with_modal_and_async_background; end

  # @label With asynchronous modal
  #
  def with_async_modal; end
end
