# frozen_string_literal: true

# == Schema Information
#
# Table name: epcis
#
#  id                   :uuid             not null, primary key
#  name                 :string           not null
#  siren                :string           not null
#  code_departement     :string
#  nature               :enum
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  communes_count       :integer          default(0), not null
#  collectivities_count :integer          default(0), not null
#
# Indexes
#
#  index_epcis_on_code_departement  (code_departement)
#  index_epcis_on_siren             (siren) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (code_departement => departements.code_departement)
#
class EPCI < ApplicationRecord
  audited

  self.implicit_order_column = :name

  # Associations
  # ----------------------------------------------------------------------------
  belongs_to :departement, primary_key: :code_departement, foreign_key: :code_departement, inverse_of: :epcis, optional: true

  has_one :region, through: :departement
  has_many :communes, primary_key: :siren, foreign_key: :siren_epci, inverse_of: :epci, dependent: false

  has_one :registered_collectivity, class_name: "Collectivity", as: :territory, dependent: false

  # Attributes
  # ----------------------------------------------------------------------------
  alias_attribute :qualified_name, :name

  # Validations
  # ----------------------------------------------------------------------------
  validates :name,  presence: true
  validates :siren, presence: true

  validates :siren,            format: { allow_blank: true, with: SIREN_REGEXP }
  validates :code_departement, format: { allow_blank: true, with: CODE_DEPARTEMENT_REGEXP }
  validates :nature, inclusion: { allow_blank: true, in: %w[ME CC CA CU] }

  validates :siren, uniqueness: { unless: :skip_uniqueness_validation_of_siren? }

  # Callbacks
  # ----------------------------------------------------------------------------
  before_validation :normalize_code_departement

  def normalize_code_departement
    self.code_departement = nil if code_departement.blank?
  end

  # Scopes
  # ----------------------------------------------------------------------------
  scope :having_communes, ->(communes) { where(siren: communes.select(:siren_epci)) }

  # Scopes: searches
  # ----------------------------------------------------------------------------
  scope :search, lambda { |input|
    advanced_search(input, scopes: {
      name:             ->(value) { match(:name, value) },
      siren:            ->(value) { where(siren: value) },
      code_departement: ->(value) { where(code_departement: value) },
      departement_name: ->(value) { left_joins(:departement).merge(Departement.search(name: value)) },
      region_name:      ->(value) { left_joins(:region).merge(Region.search(name: value)) }
    })
  }

  scope :autocomplete, lambda { |input|
    advanced_search(input, scopes: {
      name:  ->(value) { match(:name, value) },
      siren: ->(value) { where(siren: value) }
    })
  }

  # Scopes: orders
  # ----------------------------------------------------------------------------
  scope :order_by_param, lambda { |input|
    advanced_order(
      input,
      name:        ->(direction) { order_by_name(direction) },
      siren:       ->(direction) { order_by_siren(direction) },
      departement: ->(direction) { order_by_departement(direction) }
    )
  }

  scope :order_by_score, lambda { |input|
    scored_order(:name, input)
  }

  scope :order_by_name,        ->(direction = :asc) { unaccent_order(:name, direction) }
  scope :order_by_siren,       ->(direction = :asc) { order(siren: direction) }
  scope :order_by_departement, ->(direction = :asc) { order(code_departement: direction) }

  # Other associations
  # ----------------------------------------------------------------------------
  def on_territory_collectivities
    territories = [self]
    territories << communes
    territories << Departement.joins(:communes).merge(communes)

    Collectivity.kept.where(territory: territories)
  end

  # Updates methods
  # ----------------------------------------------------------------------------
  def self.reset_all_counters
    connection.select_value("SELECT reset_all_epcis_counters()")
  end
end
