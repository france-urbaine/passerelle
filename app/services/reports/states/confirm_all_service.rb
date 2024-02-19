# frozen_string_literal: true

module Reports
  module States
    class ConfirmAllService
      include ::ActiveModel::Model

      def initialize(reports)
        @reports = reports
      end

      attr_accessor :reponse

      def confirm(attributes = {})
        assign_attributes(attributes) if attributes
        validate

        if errors.empty?
          @reports.confirm_all(**attributes.to_h)
          Result::Success.new(@reports)
        else
          Result::Failure.new(errors)
        end
      end
    end
  end
end
