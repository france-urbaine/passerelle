# frozen_string_literal: true

module Transmissions
  class CompleteService
    attr_reader :transmission

    delegate :reports, :collectivity, to: :transmission

    def initialize(transmission)
      @transmission = transmission
    end

    # TODO: validate that every reports are transmissible
    #
    # include ::ActiveModel::Validations
    # include ::ActiveModel::Validations::Callbacks
    #
    # validate :validate_reports
    #
    # def validate_reports
    #   NotImplemented
    # end
    #

    def complete
      # return Result::Failure.new(errors) unless valid?

      ActiveRecord::Base.transaction do
        pack_reports
        transmission.update(completed_at: Time.current)
      end

      Result::Success.new(transmission)
    end

    def ddfips
      @ddfips ||= DDFIP.covering(transmission.reports)
        .preload(offices: :office_communes)
        .strict_loading
    end

    private

    def pack_reports
      ddfips.each do |ddfip|
        reports = transmission.reports.select { |report| report.covered_by_ddfip?(ddfip) }
        next if reports.empty?

        package = create_package(ddfip)

        reports.each.with_index do |report, index|
          office    = find_suitable_office(report, ddfip)
          reference = generate_report_reference(package, index)

          report.package   = package
          report.reference = reference
          report.ddfip     = ddfip
          report.office    = office
          report.sandbox   = transmission.sandbox
          report.transmit
          report.assign if ddfip.auto_assign_reports?
          report.save!
        end
      end
    end

    def create_package(ddfip)
      Package.create!(
        collectivity:   collectivity,
        transmission:   transmission,
        ddfip:          ddfip,
        reference:      generate_package_reference,
        sandbox:        transmission.sandbox
      )
    rescue ActiveRecord::RecordNotUnique
      retry
    end

    def generate_package_reference
      last_reference = Package.maximum(:reference)

      month = Time.zone.today.strftime("%Y-%m")
      index = last_reference&.slice(/^#{month}-(\d+)$/, 1).to_i + 1
      index = index.to_s.rjust(4, "0")

      "#{month}-#{index}"
    end

    def generate_report_reference(package, index)
      prefix = package.reference
      suffix = (index + 1).to_s.rjust(5, "0")

      "#{prefix}-#{suffix}"
    end

    def find_suitable_office(report, ddfip)
      ddfip.offices.find { |o| report.covered_by_office?(o) }
    end
  end
end
