# frozen_string_literal: true

module Packages
  class TransmissionsController < ApplicationController
    before_action { authorize! Package, with: Packages::TransmissionPolicy }

    def show
      @package = find_and_authorize_package
      @background_url = referrer_path || package_path(@package)
    end

    def update
      @package = find_and_authorize_package
      @package.touch(:transmitted_at)

      respond_with @package,
        flash: true,
        location: -> { redirect_path || package_path(@package) }
    end

    private

    def find_and_authorize_package
      package = Package.find(params[:package_id])

      authorize! package
      only_kept! package

      package
    end
  end
end
