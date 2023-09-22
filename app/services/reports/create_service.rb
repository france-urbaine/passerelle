# frozen_string_literal: true

module Reports
  class CreateService < FormService
    alias_record :report

    attr_accessor :form_type

    def initialize(report, current_user = nil, attributes = {})
      super(report, attributes)

      @current_user = current_user
      @collectivity = current_user.organization if current_user.organization.is_a?(Collectivity)
    end

    before_validation do
      record.anomalies    = []
      record.form_type    = form_type
      record.collectivity = @collectivity
      # record.package      = find_or_build_package
      # record.reference    = generate_reference
    end

    # private

    # def find_or_build_package
    #   return Package.new unless Report::FORM_TYPES.include?(record.form_type)

    #   policy   = PackagePolicy.new(user: @current_user)
    #   packages = policy.apply_scope(
    #     @collectivity.packages.order(created_at: :desc),
    #     type: :active_record_relation,
    #     name: :to_pack,
    #     scope_options: { report: record }
    #   )

    #   packages.first_or_initialize do |package|
    #     package.reference = Packages::GenerateReferenceService.new.generate
    #   end
    # end

    # def generate_reference
    #   package = record.package
    #   return unless package&.reference

    #   if package.new_record?
    #     index = "00001"
    #   else
    #     last_reference = package.reports.maximum(:reference)
    #     index = last_reference&.slice(/-(\d{5})\Z/, 1).to_i + 1
    #     index = index.to_s.rjust(5, "0")
    #   end

    #   "#{package.reference}-#{index}"
    # end
  end
end
