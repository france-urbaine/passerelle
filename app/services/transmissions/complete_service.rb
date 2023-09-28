# frozen_string_literal: true

module Transmissions
  class CompleteService < FormService
    alias_record :transmission
    delegate :collectivity, to: :transmission

    before_validation do
      @packages = create_packages
      assign_reports_to_packages

      @packages.each_value do |package|
        Packages::TransmitService.new(package).transmit
      end

      transmission.completed_at = Time.current
    end

    private

    # This method returns a Hash of new packages by form_type:
    #
    # {
    #   "evaluation_local_hab" => <Package form_type="evaluation_local_hab">
    #   "evaluation_local_pro" => <Package form_type="evaluation_local_pro">
    # }
    def create_packages
      form_types = transmission.reports.distinct.pluck(:form_type)
      form_types.to_h do |form_type|
        package = Package.create!(
          collectivity: collectivity,
          transmission: transmission,
          form_type:    form_type,
          reference:    Packages::GenerateReferenceService.new.generate
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
  end
end
