# frozen_string_literal: true

# == Schema Information
#
# Table name: publishers
#
#  id                      :uuid             not null, primary key
#  name                    :string           not null
#  siren                   :string           not null
#  contact_email           :string
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  discarded_at            :datetime
#  users_count             :integer          default(0), not null
#  collectivities_count    :integer          default(0), not null
#  contact_first_name      :string
#  contact_last_name       :string
#  contact_phone           :string
#  domain_restriction      :string
#  allow_2fa_via_email     :boolean          default(FALSE), not null
#  reports_count           :integer          default(0), not null
#  reports_completed_count :integer          default(0), not null
#  reports_approved_count  :integer          default(0), not null
#  reports_rejected_count  :integer          default(0), not null
#  reports_debated_count   :integer          default(0), not null
#  packages_count          :integer          default(0), not null
#  packages_approved_count :integer          default(0), not null
#  packages_rejected_count :integer          default(0), not null
#
# Indexes
#
#  index_publishers_on_discarded_at  (discarded_at)
#  index_publishers_on_name          (name) UNIQUE WHERE (discarded_at IS NULL)
#  index_publishers_on_siren         (siren) UNIQUE WHERE (discarded_at IS NULL)
#
class Publisher < ApplicationRecord
  # Associations
  # ----------------------------------------------------------------------------
  has_many :users, as: :organization, dependent: :delete_all
  has_many :collectivities, dependent: false

  has_many :packages, dependent: false
  has_many :reports, dependent: false

  # Validations
  # ----------------------------------------------------------------------------
  validates :name,  presence: true
  validates :siren, presence: true

  validates :siren,              format: { allow_blank: true, with: SIREN_REGEXP }
  validates :contact_email,      format: { allow_blank: true, with: EMAIL_REGEXP }
  validates :contact_phone,      format: { allow_blank: true, with: PHONE_REGEXP }
  validates :domain_restriction, format: { allow_blank: true, with: DOMAIN_REGEXP }

  validates :name,  uniqueness: {
    case_sensitive: false,
    conditions: -> { kept },
    unless: :skip_uniqueness_validation_of_name?
  }

  validates :siren, uniqueness: {
    case_sensitive: false,
    conditions: -> { kept },
    unless: :skip_uniqueness_validation_of_siren?
  }

  # Scopes
  # ----------------------------------------------------------------------------
  scope :search, lambda { |input|
    advanced_search(
      input,
      name:  ->(value) { match(:name, value) },
      siren: ->(value) { where(siren: value) }
    )
  }

  scope :autocomplete, ->(input) { search(input) }

  scope :order_by_param, lambda { |input|
    advanced_order(
      input,
      name:  ->(direction) { unaccent_order(:name, direction) },
      siren: ->(direction) { order(siren: direction) }
    )
  }

  scope :order_by_score, lambda { |input|
    scored_order(:name, input)
  }

  # Database updates
  # ----------------------------------------------------------------------------
  def self.reset_all_counters
    connection.select_value("SELECT reset_all_publishers_counters()")
  end
end
