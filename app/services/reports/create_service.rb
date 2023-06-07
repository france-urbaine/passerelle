# frozen_string_literal: true

module Reports
  class CreateService < FormService
    attr_reader :report
    attr_accessor :subject

    def initialize(report, collectivity = nil, attributes = {})
      @report       = report
      @collectivity = collectivity

      super(attributes)
      self.models = [report]
    end

    before_validation do
      @report.subject      = subject
      @report.action       = generate_action
      @report.collectivity = @collectivity
      @report.package      = find_or_build_package
      @report.reference    = generate_reference
    end

    private

    def generate_action
      return unless subject&.match(%r{\A(?<action>[^/]+)/.+})

      $LAST_MATCH_INFO[:action]
    end

    def find_or_build_package
      packages = Package.available_to(@collectivity)
      packages = packages.packing.kept.where(action: @report.action).order(created_at: :desc)
      packages.first_or_initialize do |package|
        package.name      = I18n.t(@report.action, scope: "enum.action")
        package.reference = Packages::GenerateReferenceService.new.generate
      end
    end

    def generate_reference
      package = @report.package
      return unless package&.reference

      if package.new_record?
        index = "00001"
      else
        last_reference = package.reports.maximum(:reference)
        index = last_reference&.slice(/-(\d{5})\Z/, 1).to_i + 1
        index = index.to_s.rjust(5, "0")
      end

      "#{package.reference}-#{index}"
    end
  end
end
