# frozen_string_literal: true

module Packages
  class AutoAssignService
    attr_reader :package

    def initialize(package)
      @package = package
    end

    def verify
      @package.reports.assign_all! if @package.ddfip&.auto_assign_reports?

      true
    end
  end
end
