# frozen_string_literal: true

module Transmissions
  class CompleteService < FormService
    alias_record :transmission
    delegate :collectivity, to: :transmission

    validate :validate_reports

    def validate_reports
      # TODO: validate that every reports are transmissible
    end

    def complete
      return build_result unless valid?

      transaction do
        @completed_at = Time.current
        pre_assign_reports
        transmission.update(completed_at: @completed_at)
      end

      handle_auto_assignement
      build_result
    end

    private

    def transmission_ddfips
      @transmission_ddfips ||= DDFIP.covering(transmission.reports)
        .preload(offices: :office_communes)
        .strict_loading
    end

    def pre_assign_reports
      transmission_ddfips.each do |ddfip|
        reports = transmission.reports.select { |report| report.covered_by_ddfip?(ddfip) }

        next if reports.empty?

        package = create_package(ddfip)
        reports.each.with_index do |report, index|
          office = ddfip.offices.find { |o| report.covered_by_office?(o) }
          reference = "#{package.reference}-#{(index + 1).to_s.rjust(5, '0')}"

          report.update(
            package_id:     package.id,
            reference:      reference,
            transmitted_at: @completed_at,
            state:          "sent",
            ddfip:          ddfip,
            office:         office,
            sandbox:        transmission.sandbox,
            transmission:   transmission
          )
        end
      end
    end

    def create_package(ddfip)
      Package.create!(
        collectivity:   collectivity,
        transmission:   transmission,
        ddfip:          ddfip,
        reference:      generate_reference,
        sandbox:        transmission.sandbox
      )
    rescue ActiveRecord::RecordNotUnique
      retry
    end

    def handle_auto_assignement
      transmission.packages.each do |package|
        Packages::AutoAssignService.new(package).verify
      end
    end

    def generate_reference
      last_reference = Package.maximum(:reference)

      month = Time.zone.today.strftime("%Y-%m")
      index = last_reference&.slice(/^#{month}-(\d+)$/, 1).to_i + 1
      index = index.to_s.rjust(4, "0")

      "#{month}-#{index}"
    end
  end
end
