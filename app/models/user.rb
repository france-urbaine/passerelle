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

  audited

  # Associations
  # ----------------------------------------------------------------------------
  belongs_to :organization, polymorphic: true, inverse_of: :users
  belongs_to :inviter, class_name: "User", optional: true, inverse_of: :invitees
  has_many :invitees, class_name: "User", foreign_key: :inviter_id, inverse_of: :inviter, dependent: :nullify

  has_many :office_users, dependent: false
  has_many :offices, through: :office_users

  has_many :transmissions, dependent: false
  has_one  :active_transmission, -> { active }, class_name: "Transmission", dependent: false, inverse_of: :user

  has_many :assigned_reports, class_name: "Report", dependent: false, inverse_of: :assignee

  # API applications
  has_many :access_grants, class_name: "Doorkeeper::AccessGrant", foreign_key: :resource_owner_id, dependent: :delete_all, inverse_of: false
  has_many :access_tokens, class_name: "Doorkeeper::AccessToken", foreign_key: :resource_owner_id, dependent: :delete_all, inverse_of: false

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

  scope :notifiable, -> { kept.where.not(confirmed_at: nil) }

  # Scopes: searches
  # ----------------------------------------------------------------------------
  scope :search, lambda { |input|
    advanced_search(
      input,
      default: %i[name],
      matches: {
        /@/ => %i[email unconfirmed_email]
      },
      scopes: {
        first_name:        ->(value) { match(:first_name, value) },
        last_name:         ->(value) { match(:last_name, value) },
        name:              ->(value) { search_by_full_name(value) },
        email:             ->(value) { search_with_email_attribute(:email, value) },
        unconfirmed_email: ->(value) { search_with_email_attribute(:unconfirmed_email, value) }
      }
    )
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

  # Scopes: orders
  # ----------------------------------------------------------------------------
  scope :order_by_param, lambda { |input|
    advanced_order(
      input,
      name:         ->(direction) { order_by_name(direction) },
      organisation: ->(direction) { order_by_organization(direction) }
    )
  }

  scope :order_by_score, lambda { |input|
    scored_order(:name, input)
  }

  scope :order_by_name, ->(direction = :asc) { unaccent_order(:name, direction) }
  scope :order_by_organization, lambda { |direction = :asc|
    joins(
      <<~SQL.squish
        LEFT JOIN "publishers"     ON "users"."organization_type" = 'Publisher'    AND "users"."organization_id" = "publishers"."id"
        LEFT JOIN "collectivities" ON "users"."organization_type" = 'Collectivity' AND "users"."organization_id" = "collectivities"."id"
        LEFT JOIN "ddfips"         ON "users"."organization_type" = 'DDFIP'        AND "users"."organization_id" = "ddfips"."id"
        LEFT JOIN "dgfips"         ON "users"."organization_type" = 'DGFIP'        AND "users"."organization_id" = "dgfips"."id"
      SQL
    ).unaccent_order(
      <<~SQL.squish, direction
        COALESCE("publishers"."name", "collectivities"."name", "ddfips"."name", "dgfips"."name")
      SQL
    )
  }

  # Datatable authentication
  # ----------------------------------------------------------------------------
  # Overwrite `Devise::Models::Authenticatable.find_for_authentication`
  # to exclude discarded records
  #
  # See:
  #   https://github.com/heartcombo/devise/blob/v4.9.3/lib/devise/models/authenticatable.rb#L275
  #
  def self.find_for_authentication(tainted_conditions)
    undiscarded.find_first_by_auth_conditions(tainted_conditions)
  end

  # Overwrite `Devise::Models::Authenticatable.active_for_authentication?`
  # to exclude discarded records
  #
  # See:
  #   https://github.com/heartcombo/devise/blob/v4.9.3/lib/devise/models/authenticatable.rb#L93
  #
  def active_for_authentication?
    super && !discarded?
  end

  # Use either `#update_with_password` or `#update_without_password`
  # depending on attributes to update.
  #
  # `update_without_password` never allows to change to the current password
  # without asking for the current password.
  #
  # See:
  #   https://github.com/heartcombo/devise/blob/v4.9.3/lib/devise/models/database_authenticatable.rb#L87
  #   https://github.com/heartcombo/devise/blob/v4.9.3/lib/devise/models/database_authenticatable.rb#L120
  #
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

  # 2FA authentication
  # ----------------------------------------------------------------------------
  attr_accessor :otp_code

  def setup_two_factor(otp_method = "2fa")
    self.otp_secret = User.generate_otp_secret
    self.otp_method = otp_method if otp_method
    self.otp_method = "2fa" unless organization&.allow_2fa_via_email?

    # Do not deliver this mail asynchronously,
    # because the OTP secret it not yet persisted.
    #
    # To do it asynchronously, we would pass the OTP code as an argument,
    # but it would expose the OTP code in jobs & logs.
    #
    Users::Mailer.two_factor_setup_code(self).deliver_now if send_otp_code_by_email?
  end

  def enable_two_factor(params)
    self.otp_secret  = params.fetch(:otp_secret, "")
    self.otp_code    = params.fetch(:otp_code, "")
    self.otp_method  = params.fetch(:otp_method, "2fa")
    self.otp_method  = "2fa" unless organization&.allow_2fa_via_email?
    self.otp_required_for_login = true

    if block_given?
      yield(self)
      return false if errors.any?
    end

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

    enable_two_factor(params) do
      unless valid_password?(current_password)
        errors.add(:current_password, current_password.blank? ? :blank : :invalid)
        return false
      end
    end
  end

  def send_otp_code_by_email?
    otp_method == "email" && organization&.allow_2fa_via_email?
  end

  def otp_no_longer_permitted_by_email?
    otp_method == "email" && !organization&.allow_2fa_via_email?
  end

  # This is copied from `Devise::Models::Lockable#valid_for_authentication?` and
  # inspired from Gitlab authentication flow.
  # It allows to lock user after a given number of 2FA authentication attempts
  #
  # See:
  #   https://github.com/plataformatec/devise/blob/v4.7.1/lib/devise/models/lockable.rb#L102
  #   https://github.com/gitlabhq/gitlabhq/blob/1c3cf2e3cd824cde428b686333b6e7a78fba9f76/app/models/user.rb#L2002
  #
  def increment_failed_attempts!
    increment_failed_attempts
    lock_access! if attempts_exceeded? && !access_locked?
  end

  # Devise reconfirmation
  # ----------------------------------------------------------------------------
  def cancel_pending_reconfirmation
    update(unconfirmed_email: nil)
  end

  # Reset process
  # ----------------------------------------------------------------------------
  def resetable?
    confirmed?
  end

  def reset_confirmation!
    update(
      confirmation_token: nil,
      confirmed_at: nil
    )
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

  # Make Devise::Models::Confirmable#confirmation_period_expired? public
  #
  public :confirmation_period_expired?

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

  # Notifiable
  # ----------------------------------------------------------------------------
  def notifiable?
    confirmed? && !discarded?
  end

  # Updates methods
  # ----------------------------------------------------------------------------
  def self.reset_all_counters
    connection.select_value("SELECT reset_all_users_counters()")
  end
end
