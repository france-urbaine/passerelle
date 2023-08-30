# frozen_string_literal: true

# == Schema Information
#
# Table name: dgfips
#
#  id                  :uuid             not null, primary key
#  name                :string           not null
#  contact_first_name  :string
#  contact_last_name   :string
#  contact_email       :string
#  contact_phone       :string
#  domain_restriction  :string
#  allow_2fa_via_email :boolean          default(FALSE), not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  discarded_at        :datetime
#  users_count         :integer          default(0), not null
#
# Indexes
#
#  index_dgfips_on_discarded_at  (discarded_at)
#  index_dgfips_on_name          (name) UNIQUE WHERE (discarded_at IS NULL)
#
class DGFIP < ApplicationRecord
  # Associations
  # ----------------------------------------------------------------------------
  has_many :users, as: :organization, dependent: :delete_all

  # Validations
  # ----------------------------------------------------------------------------
  validates :name, presence: true

  validates :contact_email,      format: { allow_blank: true, with: EMAIL_REGEXP }
  validates :contact_phone,      format: { allow_blank: true, with: PHONE_REGEXP }
  validates :domain_restriction, format: { allow_blank: true, with: DOMAIN_REGEXP }

  validates :name, uniqueness: {
    case_sensitive: false,
    conditions: -> { kept },
    unless: :skip_uniqueness_validation_of_name?
  }

  validate :only_one_dgfip, on: :create

  def only_one_dgfip(undiscarding: false)
    return true unless (kept? || undiscarding) && DGFIP.kept.where.not(id: id).any?

    errors.add :base, "Une seule DGFIP est possible"
    false
  end

  # Scopes
  # ----------------------------------------------------------------------------
  scope :search, lambda { |input|
    advanced_search(
      input,
      name: ->(value) { match(:name, value) }
    )
  }

  scope :autocomplete, ->(input) { search(input) }

  # Updates methods
  # ----------------------------------------------------------------------------
  def self.reset_all_counters
    connection.select_value("SELECT reset_all_dgfips_counters()")
  end

  # Overwrite to_param so DGFIP is a singular resource for url_for
  # ----------------------------------------------------------------------------
  def to_param
    nil
  end

  def undiscard
    raise ActiveRecord::RecordInvalid, self unless only_one_dgfip(undiscarding: true)

    super
  end
end
