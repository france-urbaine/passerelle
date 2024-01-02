# frozen_string_literal: true

module UI
  module Table
    # @display frame "content"
    #
    class Preview < ApplicationViewComponentPreview
      SAMPLE_DATA = [
        { id: 1, column_a: "Cell 1.A", column_b: "Cell 1.B", number1: 2,     number2: 294 },
        { id: 2, column_a: "Cell 2.A", column_b: "Cell 2.B", number1: 4_326, number2: 3572 },
        { id: 3, column_a: "Cell 3.A", column_b: "Cell 3.B", number1: 0,     number2: nil }
      ].freeze

      # @label Default HTML table
      #
      def default_with_html
        render_with_template(locals: { array_of_data: SAMPLE_DATA })
      end

      # @label Default table component
      #
      def default_with_component
        render_with_template(locals: { array_of_data: SAMPLE_DATA })
      end

      # @label With column content
      #
      def with_content
        render_with_template(locals: { array_of_data: SAMPLE_DATA })
      end

      # @label With formatted columns
      #
      def with_formatted_columns
        render_with_template(locals: { array_of_data: SAMPLE_DATA })
      end

      # @label With irregular columns
      #
      def with_irregular_columns
        render_with_template(locals: { array_of_data: SAMPLE_DATA })
      end

      # @label With checkboxes
      #
      def with_checkboxes
        render_with_template(locals: { array_of_data: SAMPLE_DATA })
      end

      # @label With actions
      #
      def with_actions
        render_with_template(locals: { array_of_data: SAMPLE_DATA })
      end

      # @label With records
      #
      def with_records
        render_with_template(locals: { records: User.limit(5) })
      end
    end
  end
end
