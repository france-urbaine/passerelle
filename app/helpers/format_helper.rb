# frozen_string_literal: true

module FormatHelper
  def display_siren(siren)
    capture do
      parts = siren.scan(/\d{3}/)
      parts[0..-2].each do |part|
        concat tag.span(part, class: "mr-1")
      end

      concat tag.span(parts[-1])
    end
  end
end
