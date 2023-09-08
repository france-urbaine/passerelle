# frozen_string_literal: true

module Packages
  class ApprovalsController < ApplicationController
    before_action { authorize! Package, with: Packages::ApprovalPolicy }

    def show
      @package = find_and_authorize_package
      redirect_to package_path(@package), status: :see_other
    end

    def update
      @package = find_and_authorize_package
      @package.approve!

      respond_with @package,
        flash: true,
        location: -> { redirect_path || package_path(@package) }
    end

    def destroy
      @package = find_and_authorize_package
      @package.return!

      respond_with @package,
        flash: true,
        location: -> { redirect_path || package_path(@package) }
    end

    private

    def find_and_authorize_package
      package = Package.find(params[:package_id])

      authorize! package, with: Packages::ApprovalPolicy
      only_kept! package

      package
    end
  end
end
