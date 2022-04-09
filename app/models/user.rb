# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id                     :uuid             not null, primary key
#  organization_type      :string           not null
#  organization_id        :uuid             not null
#  inviter_id             :uuid
#  first_name             :string           default(""), not null
#  last_name              :string           default(""), not null
#  super_admin            :boolean          default(FALSE), not null
#  organization_admin     :boolean          default(FALSE), not null
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string
#  last_sign_in_ip        :string
#  confirmation_token     :string
#  confirmed_at           :datetime
#  confirmation_sent_at   :datetime
#  unconfirmed_email      :string
#  failed_attempts        :integer          default(0), not null
#  unlock_token           :string
#  locked_at              :datetime
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  invited_at             :datetime
#
# Indexes
#
#  index_users_on_confirmation_token    (confirmation_token) UNIQUE
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_inviter_id            (inviter_id)
#  index_users_on_organization          (organization_type,organization_id)
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#  index_users_on_unlock_token          (unlock_token) UNIQUE
#
class User < ApplicationRecord
  devise(
    :database_authenticatable,
    :registerable,
    :validatable,
    :recoverable,
    :trackable,
    :confirmable,
    :timeoutable,
    :lockable
  )

  # Associations
  # ----------------------------------------------------------------------------
  belongs_to :organization, polymorphic: true, inverse_of: :users
  belongs_to :inviter, class_name: "User", optional: true, inverse_of: :invitees
  has_many :invitees, class_name: "User", foreign_key: :inviter_id, inverse_of: :inviter, dependent: :nullify

  # Validations
  # ----------------------------------------------------------------------------
  validates :last_name,  presence: true
  validates :first_name, presence: true
  validates :organization_type, inclusion: { in: %w[Publisher Collectivity DDFIP] }

  # Invitation process
  # ----------------------------------------------------------------------------
  def invite(from: nil)
    self.inviter    = from
    self.invited_at = Time.current
    self.password   = Devise.friendly_token[0, 20]
  end

  def invited?
    invited_at? && !confirmed?
  end

  def accept_invitation(params = {})
    skip_password_change_notification!
    update(params)
    confirm if errors.empty?
    self
  end

  # Sourced from Devise.
  # See Devise::Models::Confirmable.confirm_by_token
  #
  def self.find_by_invitation_token(confirmation_token)
    if confirmation_token.blank?
      confirmable = new
      confirmable.errors.add(:confirmation_token, :blank)
      return confirmable
    end

    confirmable = find_or_initialize_with_error_by(:confirmation_token, confirmation_token)
    confirmable.errors.add(:email, :already_confirmed) if confirmable.confirmed?
    confirmable
  end
end
