# frozen_string_literal: true

class ButtonComponentPreview < ViewComponent::Preview
  # @!group Basic
  #
  # @label Basic button
  #
  def basic; end

  # @label Using block to capture label
  #
  def with_block; end

  # @label Link acted as a button
  #
  def with_link; end

  # @label Link button to open in a modal
  #
  def with_modal; end

  # @label Primary button
  #
  def primary; end

  # @label Destructive button
  #
  def destructive; end
  #
  # @!endgroup

  # @!group With text and icon
  #
  # @label Text with icon
  #
  def with_icon; end

  # @label Primary button with icon
  #
  def primary_with_icon; end

  # @label Destructive button with icon
  #
  def destructive_with_icon; end
  #
  # @!endgroup

  # @!group With icon only
  #
  # @label Text with icon
  #
  def with_only_icon; end

  # @label Primary button with icon
  #
  def primary_only_icon; end

  # @label Destructive button with icon
  #
  def destructive_only_icon; end
  #
  # @!endgroup
end
