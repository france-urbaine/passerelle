# frozen_string_literal: true

module Packages
  class TransmissionPolicy < ApplicationPolicy
    def show?
      (collectivity? || publisher?) && allowed_to?(:show?, record, with: ::PackagePolicy)
    end

    def manage?
      (collectivity? || publisher?) && allowed_to?(:transmit?, record, with: ::PackagePolicy)
    end
  end
end
