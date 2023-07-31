# frozen_string_literal: true

module Packages
  class TransmitService
    attr_reader :package

    def initialize(package)
      @package = package
    end

    def transmit
      # TODO: verify package consistency
      # TODO: assign package to a single DDFIP
      @package.transmit!

      unless potential_ddfips.where(auto_approve_packages: false).exists?
        @package.approve!
      end

      true
    end

    def potential_ddfips
      reports = @package.reports
        .joins(:commune)
        .merge(Commune.select(:code_departement))

      ::DDFIP.where(code_departement: reports)
    end
  end
end
