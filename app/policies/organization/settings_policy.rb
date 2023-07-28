# frozen_string_literal: true

module Organization
  class SettingsPolicy < ApplicationPolicy
    def manage?
      organization_admin?
    end

    params_filter do |params|
      return unless organization_admin?

      params.permit(
        :name, :siren, :publisher_id,
        :contact_first_name, :contact_last_name, :contact_email, :contact_phone,
        :domain_restriction,
        :allow_2fa_via_email,
        :allow_publisher_management,
        :auto_approve_packages
      )
    end
  end
end
