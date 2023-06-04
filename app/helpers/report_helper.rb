# frozen_string_literal: true

module ReportHelper
  def validate_report_attribute(attribute, &)
    return unless @report_completeness

    if @report.transmitted? || !@report_completeness.errors.include?(attribute)
      if block_given?
        return capture(&)
      else
        return
      end
    end

    tag.div class: "flex space-x-2 text-red-500" do
      concat svg_icon("exclamation-circle", "Une erreur est présente")

      @report_completeness.errors.messages_for(attribute).each do |error|
        concat tag.span(error)
      end

      ""
    end
  end
end
