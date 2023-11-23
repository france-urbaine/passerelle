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
  belongs_to :publisher,         optional: true
  belongs_to :organization,      optional: true, polymorphic: true
  belongs_to :oauth_application, optional: true

  AUDIT_ACTION_COMPLETE = "complete"
  AUDIT_ACTION_DISCARD  = "discard"

  before_create do
    set_organization
    set_current_publisher
    set_current_application
    compute_action
  end

  private

  def set_organization
    return if user.nil?

    self.organization_id   = user.organization_id
    self.organization_type = user.organization_type
  end

  def set_current_publisher
    self.publisher = ::Audited.store[:current_publisher]
  end

  def set_current_application
    self.oauth_application = ::Audited.store[:current_application]
    self.oauth_application ||= associated if associated.is_a?(OauthApplication)
  end

  def compute_action
    if changed_attribute?(attribute: "completed_at")
      self.action = AUDIT_ACTION_COMPLETE
    elsif changed_attribute?(attribute: "discarded_at")
      self.action = AUDIT_ACTION_DISCARD
    end
  end

  def changed_attribute?(attribute:)
    auditable.respond_to?(attribute) &&
      auditable.public_send(attribute).present? &&
      audited_changes.key?(attribute) &&
      !audited_changes[attribute].nil?
  end
end
