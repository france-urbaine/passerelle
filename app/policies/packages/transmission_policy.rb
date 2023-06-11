# frozen_string_literal: true

module Packages
  class TransmissionPolicy < ApplicationPolicy
    def show?
      if record == Package
        collectivity? || publisher?
      elsif record.is_a?(Package)
        allowed_to?(:show?, record, with: ::PackagePolicy)
      end
    end

    def update?
      if record == Package
        collectivity? || publisher?
      elsif record.is_a?(Package)
        allowed_to?(:transmit?, record, with: ::PackagePolicy)
      end
    end
  end
end
