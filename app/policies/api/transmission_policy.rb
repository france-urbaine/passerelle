# frozen_string_literal: true

module API
  class TransmissionPolicy < ApplicationPolicy
    def create?
      if record == Transmission
        publisher.present?
      elsif record.is_a?(Transmission)
        publisher.present? &&
          publisher.collectivities.include?(record.collectivity)
      end
    end

    def complete?
      if record == Transmission
        publisher.present?
      elsif record.is_a?(Transmission)
        record.completed_at.nil? &&
          record.collectivity&.publisher_id == publisher.id &&
          record.reports.any? &&
          record.reports.uncompleted.none?
      end
    end

    def fill?
      record.completed_at.nil? &&
        record.collectivity.publisher_id == publisher.id
    end

    params_filter do |merged_params|
      if merged_params[:collectivity_id] && publisher.collectivities.where(id: merged_params[:collectivity_id]).any?
        merged_params.permit(:collectivity_id, :sandbox)
      else
        merged_params.permit(:sandbox)
      end
    end
  end
end
