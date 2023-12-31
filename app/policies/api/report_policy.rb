# frozen_string_literal: true

module API
  class ReportPolicy < ApplicationPolicy
    alias_rule :create?, to: :index?

    def index?
      true
    end

    def attach?
      if record == Report
        true
      elsif record.is_a?(Report)
        record.packing? &&
          publisher.present? &&
          record.publisher_id == publisher.id
      end
    end

    params_filter do |params|
      attributes = %i[form_type priority code_insee date_constat enjeu observations anomalies]
      attributes << { anomalies: [] }
      attributes << { exonerations_attributes: %i[status code label base code_collectivite] }
      attributes += Report.column_names.grep(/^(situation|proposition)_/).map(&:to_sym)

      params.permit(*attributes)
    end
  end
end
