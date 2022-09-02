# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id                     :uuid             not null, primary key
#  organization_type      :enum             not null
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
#  services_count         :integer          default(0), not null
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

  has_many :user_services, dependent: :delete_all
  has_many :services, through: :user_services

  # Validations
  # ----------------------------------------------------------------------------
  validates :last_name,  presence: true
  validates :first_name, presence: true
  validates :organization_type, inclusion: { in: %w[Publisher Collectivity DDFIP] }

  # Search
  # ----------------------------------------------------------------------------
  scope :search, lambda { |input|
    scopes = {
      first_name:        ->(value) { match(:first_name, value) },
      last_name:         ->(value) { match(:first_name, value) },
      full_name:         ->(value) { search_by_full_name(value) },
      email:             ->(value) { search_with_email_attribute(:email, value) },
      unconfirmed_email: ->(value) { search_with_email_attribute(:unconfirmed_email, value) }
    }

    case input
    when /@/    then advanced_search(input, scopes.slice(:email, :unconfirmed_email))
    when String then advanced_search(input, scopes.slice(:full_name))
    else             advanced_search(input, scopes)
    end
  }

  scope :search_by_full_name, lambda { |value|
    words = sanitize_sql_like(value).squish.split.map { |s| "%#{s}%" }

    if words.size == 1
      value = words[0]
      where(<<~SQL.squish, value:)
        LOWER(UNACCENT("users"."last_name")) LIKE LOWER(UNACCENT(:value))
        OR
        LOWER(UNACCENT("users"."first_name")) LIKE LOWER(UNACCENT(:value))
      SQL
    else
      value = words.join(" ")
      where(<<~SQL.squish, value:)
        LOWER(UNACCENT(CONCAT("users"."last_name", ' ', "users"."first_name"))) LIKE LOWER(UNACCENT(:value))
        OR
        LOWER(UNACCENT(CONCAT("users"."first_name", ' ', "users"."last_name"))) LIKE LOWER(UNACCENT(:value))
      SQL
    end
  }

  scope :search_with_email_attribute, lambda { |attribute, value|
    if value.start_with?("@")
      where(arel_table[attribute].matches("%#{sanitize_sql_like(value)}", nil, true))
    else
      where(attribute => value)
    end
  }

  scope :order_by_score, lambda { |input|
    scored_order("CONCAT(users.first_name, ' ', users.last_name)", input)
  }

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

  # Counters cached
  # ----------------------------------------------------------------------------
  def self.reset_all_counters
    connection.select_value("SELECT reset_all_users_counters()")
  end
end
