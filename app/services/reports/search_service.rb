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
      "etat"       => "state",
      "adresse"    => "address",
      "paquet"     => "package",
      "formulaire" => "form_type"
    }.freeze

    def tanslate_param_keys(hash)
      hash = hash.transform_keys { |k| I18n.transliterate(k).downcase }

      PARAM_KEY_TRANSLATOR.each do |from, to|
        hash[to] ||= hash.delete(from) if hash.key?(from)
      end

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

    def tanslate_param_values(hash)
      hash["state"] = translate_state_values(hash["state"]) if hash["state"]
      hash
    end

    def translate_state_values(values)
      case @organization_type
      when :collectivity
        conversions  = STATE_VALUE_CONVERSIONS.fetch(:collectivity)
        translations = I18n.t(:collectivity, scope: "enum.search_state", raise: true)
      when :ddfip_admin, :ddfip_user
        conversions  = STATE_VALUE_CONVERSIONS.fetch(:ddfip)
        translations = I18n.t(@organization_type, scope: "enum.search_state", raise: true)
      else
        return values
      end

      translations = translations.transform_values { |label| I18n.transliterate(label).downcase }
      values       = Array.wrap(values)

      # First translate french values into keywords
      values = values.flat_map { |state|
        state    = I18n.transliterate(state).downcase.squish
        keywords = translations
          .select { |_, label| label.include?(state) }
          .keys

        state = keywords.map(&:to_s) if keywords.any?
        state
      }.uniq.compact

      # Then convert keywords to the one the organization can see
      values.flat_map { |state|
        conversions[state] || "unknown"
      }.uniq.compact
    end
  end
end
