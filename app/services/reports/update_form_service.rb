# frozen_string_literal: true

module Reports
  class UpdateFormService
    # Use proper names and keys in form builders
    def self.model_name
      Report.model_name
    end

    attr_reader :report, :fields

    delegate_missing_to :report

    FIELDS = %w[
      situation_majic
      situation_evaluation_hab
      situation_evaluation_hab
      proposition_evaluation_hab
      observations
      enjeux
      priority
    ].freeze

    def initialize(report, fields)
      raise ArgumentError, "unexpected fields: #{fields}" unless FIELDS.include?(fields)

      @report = report
      @fields = fields
    end

    def code_insee_options
      report.collectivity.on_territory_communes.pluck(:name, :code_insee)
    end

    def affectation_options
      I18n.t("enum.affectation").map(&:reverse)
    end

    def nature_options
      I18n.t("enum.nature_local").map(&:reverse)
    end

    def categorie_label
      case action
      when "evaluation_hab", "occupation_hab"
        "Catégorie de local d'habitation"
      else
        "Catégorie de local économique"
      end
    end

    def categorie_options
      case action
      when "evaluation_hab", "occupation_hab"
        I18n.t("enum.categorie_habitation").map(&:reverse)
      else
        I18n.t("enum.categorie_economique").map(&:reverse)
      end
    end

    def situation_date_mutation
      parse_date(report.situation_date_mutation) if report.situation_date_mutation
    end

    def coefficient_entretien_options
      I18n.t("enum.coefficient_entretien").map(&:reverse)
    end

    def coefficient_situation_options
      I18n.t("enum.coefficient_situation").map(&:reverse)
    end

    def priority_options
      I18n.t("enum.priority").map(&:reverse)
    end

    protected

    def parse_date(date)
      return unless date.match(ApplicationRecord::DATE_REGEXP)

      # The API might send pseudo-date without days or months
      # This helper ignores missing information to return a full date
      #
      # We don't really care because date edited through this form should have been
      # filled by datefield inputs and be full-date.
      #
      args = $LAST_MATCH_INFO.values_at(:year, :month, :day).compact.map(&:to_i)
      Date.new(*args)
    end
  end
end
