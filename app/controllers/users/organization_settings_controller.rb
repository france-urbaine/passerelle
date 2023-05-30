# frozen_string_literal: true

module Users
  class OrganizationSettingsController < ApplicationController
    before_action { authorize! with: Users::OrganizationSettingsPolicy }

    def show
      @organization = current_user.organization
    end

    def update
      @organization = current_user.organization
      @organization.update(organisation_params)

      respond_with @organization,
        action: :show,
        flash: true,
        location: user_organization_settings_path
    end

    private

    def organisation_params
      params
        .fetch(:organization, {})
        .permit(
          :name, :siren,
          :contact_first_name, :contact_last_name, :contact_email, :contact_phone,
          :domain_restriction, :allow_2fa_via_email
        )
    end
  end
end
