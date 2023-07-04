# frozen_string_literal: true

# rubocop:disable Rails/HelperInstanceVariable
# These helpers requires @report & @report_completeness instances to work
# It will be redundant to specify them at each call
#
module ReportHelper
  def validate_report_attribute(attribute, &)
    return unless @report && @report_completeness

    if @report.transmitted? || !@report_completeness.errors.include?(attribute) # rubocop:disable Rails/NegateInclude
      content = capture(&) if block_given?
      return content
    end

    tag.span class: "flex space-x-2 text-red-500" do
      concat svg_icon("exclamation-circle", "Une erreur est présente")

      @report_completeness.errors.messages_for(attribute).each do |error|
        concat tag.span(error)
      end

      ""
    end
  end
end
# rubocop:enable Rails/HelperInstanceVariable
