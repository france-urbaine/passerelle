# frozen_string_literal: true

module Users
  class CreateService < UpdateService
    # This service class inherits UpdateService setters for organization & offices:
    #   def organization_data=
    #   def organization_name=
    #   def office_ids=

    def initialize(*, invited_by: nil, organization: nil)
      super(*)

      @inviter      = invited_by
      @organization = organization
    end

    before_validation do
      user.password = Devise.friendly_token[0, 20]
      user.organization = @organization if @organization
    end

    before_save do
      user.inviter = @inviter
      user.invited_at = Time.current
    end
  end
end
