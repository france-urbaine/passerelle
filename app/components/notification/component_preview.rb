# frozen_string_literal: true

module Notification
  class ComponentPreview < ApplicationViewComponentPreview
    # @label Default
    #
    def default; end

    # @!group With types
    #
    # @label With information type
    #
    def with_type_information; end

    # @label With success type
    #
    def with_type_success; end

    # @label With error type
    #
    def with_type_error; end

    # @label With cancel type
    #
    def with_type_cancel; end
    #
    # @!endgroup

    # @label With description
    #
    def with_description; end

    # @label With actions
    #
    def with_actions; end
  end
end
