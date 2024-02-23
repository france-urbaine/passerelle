# frozen_string_literal: true

module Reports
  class SearchService
    def initialize(reports = Report.all, as: nil)
      @reports           = reports
      @organization_type = as
    end

    def search(param)
      param = analyze_param(param)

      reports = @reports
      reports = reports.search(param) if param.present?
      reports
    end

    def analyze_param(input)
      return if input.blank?

      string, hash = Report.parse_advanced_search_input(input)
      hash = tanslate_param_keys(hash)
      hash = tanslate_param_values(hash)

      if string.blank?
        hash
      else
        Report.flatten_advanced_search_input(string, hash)
      end
    end

    protected

    PARAM_KEY_TRANSLATOR = {
      "etat"         => "state",
      "adresse"      => "address",
      "paquet"       => "package",
      "type"         => "form_type",
      "objet"        => "anomalies",
      "priorite"     => "priority",
      "collectivite" => "collectivity",
      "guichet"      => "office"
    }.freeze

    def tanslate_param_keys(hash)
      hash = hash.transform_keys { |k| I18n.transliterate(k).downcase }

      PARAM_KEY_TRANSLATOR.each do |from, to|
        hash[to] ||= hash.delete(from) if hash.key?(from)
      end

      hash
    end

    def tanslate_param_values(hash)
      hash["state"]     = translate_state_values(hash["state"]) if hash.key?("state")
      hash["form_type"] = EnumMatcher.select(hash["form_type"], "enum.report_form_type") if hash.key?("form_type")
      hash["anomalies"] = EnumMatcher.select(hash["anomalies"], "enum.anomalies")        if hash.key?("anomalies")
      hash["priority"]  = EnumMatcher.select(hash["priority"], "enum.priority")          if hash.key?("priority")
      hash
    end

    STATE_VALUE_CONVERSIONS = {
      collectivity: {
        "draft"       => %w[draft],
        "ready"       => %w[ready],
        "transmitted" => %w[transmitted acknowledged],
        "accepted"    => %w[accepted assigned applicable inapplicable],
        "approved"    => %w[approved],
        "canceled"    => %w[canceled],
        "rejected"    => %w[rejected],
        "returned"    => %w[approved canceled rejected]
      },
      ddfip: {
        "transmitted"  => %w[transmitted acknowledged],
        "accepted"     => %w[accepted],
        "assigned"     => %w[assigned],
        "applicable"   => %w[applicable],
        "inapplicable" => %w[inapplicable],
        "resolved"     => %w[applicable inapplicable],
        "approved"     => %w[approved],
        "canceled"     => %w[canceled],
        "rejected"     => %w[rejected],
        "returned"     => %w[approved canceled rejected]
      }
    }.freeze

    def translate_state_values(values)
      case @organization_type
      when :collectivity
        conversions  = STATE_VALUE_CONVERSIONS.fetch(:collectivity)
        i18n_path    = "enum.search_state.collectivity"
      when :ddfip_admin, :ddfip_user
        conversions  = STATE_VALUE_CONVERSIONS.fetch(:ddfip)
        i18n_path    = "enum.search_state.#{@organization_type}"
      else
        return values
      end

      # First translate values into keywords if they're are not
      # Then convert keywords to the one the organization can see
      EnumMatcher.select(values, i18n_path)
        .flat_map { |state| conversions[state] }
        .uniq.compact
    end
  end
end
