# frozen_string_literal: true

class AuditResolver
  ACTION_CHANGE_ORGANIZATION               = "change_organization"
  ACTION_CHANGE_ORGANIZATION_AND_UPDATE    = "change_organization_and_update"
  ACTION_COMPLETE                          = "complete"
  ACTION_DISCARD                           = "discard"
  ACTION_LOGIN                             = "login"
  ACTION_TWO_FACTORS                       = "two_factors"

  def self.resolve_action(audit)
    return if audit.action == "create"

    case [audit.auditable_type, audit.audited_changes&.with_indifferent_access]
    in [_, { discarded_at: _ }]
      ACTION_DISCARD
    in ["Report", { completed_at: _ }] | ["Transmission", { completed_at: _ }]
      ACTION_COMPLETE
    in ["User", { consumed_timestep: _ }]
      ACTION_TWO_FACTORS
    in ["User", { sign_in_count: _, last_sign_in_at: _, current_sign_in_at: _ }]
      ACTION_LOGIN
    in ["User", { organization_id: _, **other }]
      other.except(:organization_type).any? ? ACTION_CHANGE_ORGANIZATION_AND_UPDATE : ACTION_CHANGE_ORGANIZATION
    else
      nil
    end
  end
end
