# frozen_string_literal: true

module UI
  # @display frame "content"
  # @display width "small"
  #
  class BadgeComponentPreview < ::Lookbook::Preview
    # @label Default
    #
    def default; end

    # @label All colors
    #
    def all_colors; end

    # @!group Inside other elements
    #
    # @label Inside a description list
    #
    def inside_description_list; end

    # @label Inside a table
    #
    def inside_table; end
    #
    # @!endgroup
  end
end
