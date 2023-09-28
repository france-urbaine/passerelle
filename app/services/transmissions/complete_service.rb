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
        @packages     = create_packages

        assign_reports_to_packages
        transmission.update(completed_at: @completed_at)
      end

      handle_auto_assignement

      build_result
    end

    private

    # This method returns a Hash of new packages by form_type:
    #
    # {
    #   "evaluation_local_hab" => <Package form_type="evaluation_local_hab">
    #   "evaluation_local_pro" => <Package form_type="evaluation_local_pro">
    # }
    #
    # TODO: create a package for each targeted office
    #
    def create_packages
      form_types = transmission.reports.distinct.pluck(:form_type)
      form_types.to_h do |form_type|
        package = Package.create!(
          collectivity:   collectivity,
          transmission:   transmission,
          form_type:      form_type,
          reference:      Packages::GenerateReferenceService.new.generate,
          transmitted_at: @completed_at
        )

        [form_type, package]
      end
    end

    # This method yields a hash of new attributes to assign to reports
    # (in batches)
    #
    #   {
    #     "5f78720a-d90a-4924-[..]" => { reference: "2023-0009-0001", package_id: "52505b7f-7418-4cec-[..]" }
    #     "b0a29e23-b293-4c94-[..]" => { reference: "2023-0009-0001", package_id: "52505b7f-7418-4cec-[..]" }
    #   }
    #

    def each_reports_assignments_in_batches
      return to_enum(:each_reports_assignments_in_batches) unless block_given?

      @packages.each do |form_type, package|
        report_index = 1

        transmission.reports.where(form_type:).select(:id).find_in_batches do |reports|
          assignements = {}

          reports.each do |report|
            reference_index = report_index.to_s.rjust(5, "0")
            reference       = "#{package.reference}-#{reference_index}"

            assignements[report.id] = {
              package_id: package.id,
              reference:  reference
            }

            report_index += 1
          end

          yield assignements
        end
      end
    end

    def assign_reports_to_packages
      each_reports_assignments_in_batches do |reports|
        # TODO: perform update in one query per batch

        Report.update(reports.keys, reports.values)
      end
    end

    def handle_auto_assignement
      @packages.each_value do |package|
        Packages::AutoAssignService.new(package).verify
      end
    end
  end
end
