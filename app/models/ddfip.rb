# frozen_string_literal: true

# == Schema Information
#
# Table name: ddfips
#
#  id                     :uuid             not null, primary key
#  name                   :string           not null
#  code_departement       :string           not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  discarded_at           :datetime
#  users_count            :integer          default(0), not null
#  collectivities_count   :integer          default(0), not null
#  offices_count          :integer          default(0), not null
#  contact_first_name     :string
#  contact_last_name      :string
#  contact_email          :string
#  contact_phone          :string
#  domain_restriction     :string
#  allow_2fa_via_email    :boolean          default(FALSE), not null
#  reports_count          :integer          default(0), not null
#  reports_approved_count :integer          default(0), not null
#  reports_rejected_count :integer          default(0), not null
#  reports_debated_count  :integer          default(0), not null
#
# Indexes
#
#  index_ddfips_on_code_departement  (code_departement)
#  index_ddfips_on_discarded_at      (discarded_at)
#  index_ddfips_on_name              (name) UNIQUE WHERE (discarded_at IS NULL)
#
# Foreign Keys
#
#  fk_rails_...  (code_departement => departements.code_departement)
#
class DDFIP < ApplicationRecord
  # Associations
  # ----------------------------------------------------------------------------
  belongs_to :departement, primary_key: :code_departement, foreign_key: :code_departement, inverse_of: :ddfips

  has_many :epcis,    primary_key: :code_departement, foreign_key: :code_departement, inverse_of: false, dependent: false
  has_many :communes, primary_key: :code_departement, foreign_key: :code_departement, inverse_of: false, dependent: false
  has_one  :region, through: :departement

  has_many :users, as: :organization, dependent: :delete_all

  has_many :offices,   dependent: false
  has_many :workshops, dependent: false

  # Validations
  # ----------------------------------------------------------------------------
  validates :name,             presence: true
  validates :code_departement, presence: true

  validates :code_departement,   format: { allow_blank: true, with: CODE_DEPARTEMENT_REGEXP }
  validates :contact_email,      format: { allow_blank: true, with: EMAIL_REGEXP }
  validates :contact_phone,      format: { allow_blank: true, with: PHONE_REGEXP }
  validates :domain_restriction, format: { allow_blank: true, with: DOMAIN_REGEXP }

  validates :name, uniqueness: {
    case_sensitive: false,
    conditions: -> { kept },
    unless: :skip_uniqueness_validation_of_name?
  }

  # Scopes
  # ----------------------------------------------------------------------------
  scope :search, lambda { |input|
    advanced_search(
      input,
      name:             ->(value) { match(:name, value) },
      code_departement: ->(value) { where(code_departement: value) },
      departement_name: ->(value) { left_joins(:departement).merge(Departement.match(:name, value)) },
      region_name:      ->(value) { left_joins(:region).merge(Region.match(:name, value)) }
    )
  }

  scope :autocomplete, lambda { |input|
    advanced_search(
      input,
      name:             ->(value) { match(:name, value) },
      code_departement: ->(value) { where(code_departement: value) }
    )
  }

  scope :order_by_param, lambda { |input|
    advanced_order(
      input,
      name:        ->(direction) { unaccent_order(:name, direction) },
      departement: ->(direction) { order(code_departement: direction) },
      region:      ->(direction) { left_joins(:departement).order(code_region: direction) }
    )
  }

  scope :order_by_score, lambda { |input|
    scored_order(:name, input)
  }

  # Other associations
  # ----------------------------------------------------------------------------
  def on_territory_collectivities
    territories = []
    territories << communes
    territories << EPCI.joins(:communes).merge(communes)
    territories << Departement.where(code_departement: code_departement)

    Collectivity.kept.where(territory: territories)
  end

  # Database updates
  # ----------------------------------------------------------------------------
  def self.reset_all_counters
    connection.select_value("SELECT reset_all_ddfips_counters()")
  end
end
