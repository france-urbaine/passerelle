# frozen_string_literal: true

module API
  class TransmissionPolicy < ApplicationPolicy
    def create?
      publisher.present?
    end

    def complete?
      if record == Transmission
        publisher.present?
      elsif record.is_a?(Transmission)
        record.completed_at.nil? &&
          record.reports.any? &&
          record.reports.incomplete.none?
      end
    end

    def fill?
      record.completed_at.nil? &&
        record.collectivity.publisher_id == publisher.id
    end

    params_filter do |params|
      params.permit(:sandbox)
    end
  end
end
