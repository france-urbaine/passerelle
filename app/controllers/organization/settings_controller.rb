# frozen_string_literal: true

module Organization
  class SettingsController < ApplicationController
    before_action :authorize!

    def show
      @organization = current_organization
    end

    def update
      @organization = current_organization
      @organization.update(organisation_params)

      respond_with @organization,
        action: :show,
        flash: true,
        location: organization_settings_path
    end

    private

    def implicit_authorization_target
      :settings
    end

    def organisation_params
      authorized(params.fetch(:organization, {}))
    end
  end
end
