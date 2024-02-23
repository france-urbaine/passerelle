# frozen_string_literal: true

module Reports
  class SearchService
    def initialize(reports = Report.all, as: nil)
      @reports           = reports
      @organization_type = as&.to_s&.underscore
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
      "etat" => "state"
    }.freeze

    def tanslate_param_keys(hash)
      hash = hash.transform_keys { |k| I18n.transliterate(k) }

      PARAM_KEY_TRANSLATOR.each do |from, to|
        hash[to] ||= hash.delete(from) if hash.key?(from)
      end

      hash
    end

    STATE_VALUE_TRANSLATOR = {
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
      when "collectivity", "publisher" then translations = STATE_VALUE_TRANSLATOR[:collectivity]
      when "ddfip", "dgip"             then translations = STATE_VALUE_TRANSLATOR[:ddfip]
      else
        return values
      end

      Array.wrap(values)
        .flat_map { |state| translations[state] || "unknown" }
        .compact
    end
  end
end
