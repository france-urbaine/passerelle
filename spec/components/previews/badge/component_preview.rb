# frozen_string_literal: true

module Badge
  # @logical_path Layout components
  # @display frame "content"
  # @display width "small"
  #
  class ComponentPreview < ::Lookbook::Preview
    # @label Default
    #
    def default; end

    # @label Reports
    #
    def report_badges; end

    # @label Packages
    #
    def package_badges; end

    # @label Priorities
    #
    def priority_badges; end
  end
end
