# frozen_string_literal: true

module Packages
  class ReportsController < ::ReportsController
    private

    def load_and_authorize_parent
      package = Package.find(params[:package_id])

      authorize! package, to: :show?
      only_kept! package

      @parent = package
    end

    def build_and_authorize_scope(as: :default)
      authorized(@parent.reports, as:).strict_loading
    end
  end
end
