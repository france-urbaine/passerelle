# frozen_string_literal: true

# == Schema Information
#
# Table name: audits
#
#  id                   :uuid             not null, primary key
#  auditable_id         :uuid
#  auditable_type       :string
#  associated_id        :uuid
#  associated_type      :string
#  user_id              :uuid
#  user_type            :string
#  username             :string
#  publisher_id         :uuid
#  organization_id      :uuid
#  organization_type    :string
#  oauth_application_id :uuid
#  action               :string
#  audited_changes      :jsonb
#  version              :integer          default(0)
#  comment              :string
#  remote_address       :string
#  request_uuid         :string
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
# Indexes
#
#  index_audits_on_associated_type_and_associated_id            (associated_type,associated_id)
#  index_audits_on_auditable_type_and_auditable_id_and_version  (auditable_type,auditable_id,version)
#  index_audits_on_created_at                                   (created_at)
#  index_audits_on_request_uuid                                 (request_uuid)
#  index_audits_on_user_id_and_user_type                        (user_id,user_type)
#
class Audit < Audited::Audit
  self.implicit_order_column = :created_at

  belongs_to :publisher,         optional: true
  belongs_to :organization,      optional: true, polymorphic: true
  belongs_to :oauth_application, optional: true

  before_create do
    set_organization
    set_current_application_and_publisher
    resolve_action
  end

  def resolve_action!
    resolve_action
    save! if changed?
  end

  private

  def set_organization
    return if user.nil?

    self.organization_id   = user.organization_id
    self.organization_type = user.organization_type
  end

  def set_current_application_and_publisher
    self.oauth_application = ::Audited.store[:current_application]
    self.oauth_application ||= associated if associated.is_a?(OauthApplication)

    self.publisher = ::Audited.store[:current_publisher]
    self.publisher ||= oauth_application&.owner if oauth_application&.owner_type == "Publisher"
  end

  def resolve_action
    resolved_action = AuditResolver.resolve_action(self)
    return if resolved_action.nil?

    self.action = resolved_action
    self.user   ||= auditable if action == AuditResolver::ACTION_LOGIN || action == AuditResolver::ACTION_TWO_FACTORS
  end
end
