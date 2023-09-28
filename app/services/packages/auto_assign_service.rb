# frozen_string_literal: true

module Packages
  class AutoAssignService
    attr_reader :package

    def initialize(package)
      @package = package
    end

    def verify
      # The workflow is simplified :
      # packages are auto-assigned.
      @package.assign!

      true
    end
  end
end
