# frozen_string_literal: true

module API
  class TransmissionPolicy < ApplicationPolicy
    def create?
      publisher?
    end

    def complete?
      if record == Transmission
        publisher?
      elsif record.is_a?(Transmission)
        publisher? &&
          record.publisher_id == publisher.id &&
          record.active? &&
          record.reports.any? &&
          record.reports.incomplete.none?
      end
    end

    def fill?
      if record == Transmission
        publisher?
      elsif record.is_a?(Transmission)
        publisher? &&
          record.publisher_id == publisher.id &&
          record.active?
      end
    end

    params_filter do |params|
      params.permit(:sandbox)
    end
  end
end
