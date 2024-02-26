# frozen_string_literal: true

module EnumMatcher
  module_function

  def select(input, i81n_path, raise: true)
    translations = I18n.t(i81n_path, raise:)
    translations = translations.select { |_, label| label.is_a?(String) }
    translations = translations.transform_values { |label| I18n.transliterate(label).downcase }

    values = Array.wrap(input)
    values = values.flat_map do |value|
      value = I18n.transliterate(value).downcase.squish
      keys  = translations.select { |_, label| label.include?(value) }
      value = keys.keys.map(&:to_s) if keys.any?
      value
    end

    values.uniq.compact
  end
end
