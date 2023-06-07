# frozen_string_literal: true

module Packages
  class GenerateReferenceService
    def generate
      last_reference = Package.maximum(:reference)

      month = Time.zone.today.strftime("%Y-%m")
      index = last_reference&.slice(/^#{month}-(\d+)$/, 1).to_i + 1
      index = index.to_s.rjust(4, "0")

      "#{month}-#{index}"
    end
  end
end
