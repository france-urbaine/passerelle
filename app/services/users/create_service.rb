# frozen_string_literal: true

module Users
  class CreateService < UpdateService
    # This service class inherits UpdateService setters for organization & offices:
    #   def organization_data=
    #   def organization_name=
    #   def office_ids=

    delegate :office_users, to: :record

    def initialize(*, invited_by: nil, organization: nil)
      super(*)

      @inviter      = invited_by
      @organization = organization
    end

    validate :any_office_users, if: :inviter_is_a_supervisor?

    before_validation do
      user.password = Devise.friendly_token[0, 20]
      user.organization = @organization if @organization
    end

    before_save do
      user.inviter = @inviter
      user.invited_at = Time.current
    end

    private

    def any_office_users
      errors.add(:office_users, :blank) if office_users.empty?
      record.errors.add(:office_users, :blank) if office_users.empty?
    end

    def inviter_is_a_supervisor?
      !@inviter.super_admin && !@inviter.organization_admin &&
        @inviter.office_users.where(supervisor: true).any?
    end
  end
end
