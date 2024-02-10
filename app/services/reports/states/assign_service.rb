# frozen_string_literal: true

module Reports
  module States
    class AssignService
      include ::ActiveModel::Validations

      def initialize(report)
        @report = report
      end

      def assign(attributes = {})
        @report.assign_attributes(attributes) if attributes
        @report.validate
        @report.errors.add(:office_id, :blank) if @report.office_id.nil?
        @report.assign! if @report.errors.empty?

        build_result
      end

      def undo
        @report.undo_assignment!

        build_result
      end

      private

      def build_result
        errors.clear
        errors.merge!(@report.errors)

        if errors.empty?
          Result::Success.new(@report)
        else
          Result::Failure.new(errors)
        end
      end
    end
  end
end
