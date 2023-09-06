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
#  name                   :string           default(""), not null
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
#  discarded_at           :datetime
#  offices_count          :integer          default(0), not null
#  otp_secret             :string
#  otp_method             :enum             default("2fa"), not null
#  consumed_timestep      :integer
#  otp_required_for_login :boolean          default(TRUE), not null
#
# Indexes
#
#  index_users_on_confirmation_token    (confirmation_token) UNIQUE
#  index_users_on_discarded_at          (discarded_at)
#  index_users_on_email                 (email) UNIQUE WHERE (discarded_at IS NULL)
#  index_users_on_inviter_id            (inviter_id)
#  index_users_on_organization          (organization_type,organization_id)
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#  index_users_on_unlock_token          (unlock_token) UNIQUE
#
class User < ApplicationRecord
  # Devise validatable is not included:
  # Validations are included manually to scope on kept records
  # when validating uniqueness of email.
  #
  devise(
    :two_factor_authenticatable,
    :recoverable,
    :trackable,
    :confirmable,
    :timeoutable,
    :lockable,
    :zxcvbnable
  )

  # Associations
  # ----------------------------------------------------------------------------
  belongs_to :organization, polymorphic: true, inverse_of: :users
  belongs_to :inviter, class_name: "User", optional: true, inverse_of: :invitees
  has_many :invitees, class_name: "User", foreign_key: :inviter_id, inverse_of: :inviter, dependent: :nullify

  has_many :office_users, dependent: false
  has_many :offices, through: :office_users

  # Validations
  # ----------------------------------------------------------------------------
  validates :first_name, presence: true
  validates :last_name,  presence: true
  validates :email,      presence: true
  validates :password,   presence: { if: :password_required? }

  validates :organization_type, inclusion: { in: %w[Publisher Collectivity DDFIP DGFIP] }

  with_options allow_blank: true do
    validates :email, format: { with: Devise.email_regexp, if: :will_save_change_to_email? }
    validates :email, uniqueness: {
      case_sensitive: false,
      conditions: -> { kept },
      unless: :skip_uniqueness_validation_of_email?
    }

    validates :password, confirmation: { if: :password_required? }
    validates :password, length: { within: Devise.password_length }
  end

  validate if: :will_save_change_to_email? do |user|
    domain = user.organization&.domain_restriction
    next if domain.blank?

    regexp = build_email_regexp(domain)
    errors.add(:email, :invalid_domain, domain: domain) unless regexp.match?(user.email)
  end

  # Checks whether a password is needed or not. For validations only.
  # Passwords are always required if it's a new record, or if the password
  # or confirmation are being set somewhere.
  def password_required?
    !persisted? || !password.nil? || !password_confirmation.nil?
  end

  # Callbacks
  # ----------------------------------------------------------------------------
  before_save :generate_name

  def generate_name
    self.name = "#{first_name} #{last_name}".strip
  end

  # Scopes
  # ----------------------------------------------------------------------------
  scope :owned_by, ->(organization) { where(organization: organization) }

  scope :search, lambda { |input|
    scopes = {
      first_name:        ->(value) { match(:first_name, value) },
      last_name:         ->(value) { match(:last_name, value) },
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

  scope :order_by_param, lambda { |input|
    advanced_order(
      input,
      name:         ->(direction) { unaccent_order(:name, direction) },
      organisation: lambda { |direction|
        joins(<<~SQL.squish)
          LEFT JOIN publishers     ON users.organization_type = 'Publisher'    AND users.organization_id = publishers.id
          LEFT JOIN collectivities ON users.organization_type = 'Collectivity' AND users.organization_id = collectivities.id
          LEFT JOIN ddfips         ON users.organization_type = 'DDFIP'        AND users.organization_id = ddfips.id
          LEFT JOIN dgfips         ON users.organization_type = 'DGFIP'        AND users.organization_id = dgfips.id
        SQL
        .unaccent_order("COALESCE(publishers.name, collectivities.name, ddfips.name, dgfips.name)", direction)
      }
    )
  }

  scope :order_by_score, lambda { |input|
    scored_order(:name, input)
  }

  # Security & 2FA
  # ----------------------------------------------------------------------------
  def self.find_for_authentication(tainted_conditions)
    undiscarded.find_first_by_auth_conditions(tainted_conditions)
  end

  def active_for_authentication?
    super() && !discarded?
  end

  def update_with_password_protection(params)
    if params.include?(:email) || params.include?(:password)
      update_with_password(params)
    else
      params.delete(:email)
      params.delete(:super_admin)
      params.delete(:organization_admin)
      update_without_password(params)
    end
  end

  attr_accessor :otp_code

  def enable_two_factor(params)
    self.otp_secret  = params.fetch(:otp_secret, "")
    self.otp_code    = params.fetch(:otp_code, "")
    self.otp_method  = params.fetch(:otp_method, "2fa")
    self.otp_method  = "2fa" unless organization&.allow_2fa_via_email?
    self.otp_required_for_login = true

    unless validate_and_consume_otp!(otp_code)
      errors.add(:otp_code, otp_code.blank? ? :blank : :invalid)
      return false
    end

    Users::Mailer.two_factor_change(self).deliver_later

    self.otp_code = nil
    true
  end

  def enable_two_factor_with_password(params)
    current_password = params.fetch(:current_password, "")
    self.otp_secret  = params.fetch(:otp_secret, "")
    self.otp_code    = params.fetch(:otp_code, "")
    self.otp_method  = params.fetch(:otp_method, "2fa")
    self.otp_method  = "2fa" unless organization&.allow_2fa_via_email?
    self.otp_required_for_login = true

    unless valid_password?(current_password)
      errors.add(:current_password, current_password.blank? ? :blank : :invalid)
      return false
    end

    unless validate_and_consume_otp!(otp_code)
      errors.add(:otp_code, otp_code.blank? ? :blank : :invalid)
      return false
    end

    Users::Mailer.two_factor_change(self).deliver_later

    self.otp_code = nil
    true
  end

  def send_otp_code_by_email?
    otp_method == "email" && organization&.allow_2fa_via_email?
  end

  # Devise delivery method
  # ----------------------------------------------------------------------------
  def send_devise_notification(notification, *)
    devise_mailer.send(notification, self, *).deliver_later
  end

  # Devise reconfirmation
  # ----------------------------------------------------------------------------
  def cancel_pending_reconfirmation
    update(unconfirmed_email: nil)
  end

  # Invitation process
  # ----------------------------------------------------------------------------
  def invite(by: nil)
    self.inviter    = by
    self.invited_at = Time.current
    self.password   = Devise.friendly_token[0, 20]
    self
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
    confirmable.validate_pending_confirmation
    confirmable
  end

  def validate_pending_confirmation
    errors.add(:email, :already_confirmed) if confirmed?

    if confirmation_period_expired?
      errors.add(:email, :confirmation_period_expired,
        period: Devise::TimeInflector.time_ago_in_words(self.class.confirm_within.ago))
    end

    errors.empty?
  end

  # Updates methods
  # ----------------------------------------------------------------------------
  def self.reset_all_counters
    connection.select_value("SELECT reset_all_users_counters()")
  end
end
