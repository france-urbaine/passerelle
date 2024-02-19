# frozen_string_literal: true

module Reports
  module States
    class AssignAllService
      include ::ActiveModel::Model

      def initialize(reports)
        @reports = reports
      end

      attr_accessor :office_id

      validates :office_id, presence: true

      def assign(attributes = {})
        assign_attributes(attributes) if attributes
        validate

        if errors.empty?
          @reports.assign_all(**attributes.to_h)
          Result::Success.new(@reports)
        else
          Result::Failure.new(errors)
        end
      end
    end
  end
end
