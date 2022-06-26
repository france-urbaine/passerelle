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
class EPCI < ApplicationRecord
  self.implicit_order_column = :name

  # Associations
  # ----------------------------------------------------------------------------
  belongs_to :departement, primary_key: :code_departement, foreign_key: :code_departement, inverse_of: :epcis, optional: true, counter_cache: true

  has_one :region, through: :departement
  has_many :communes, primary_key: :siren, foreign_key: :siren_epci, inverse_of: :epci, dependent: false

  has_one :registered_collectivity, class_name: "Collectivity", as: :territory, dependent: false

  # Validations
  # ----------------------------------------------------------------------------
  validates :name,  presence: true
  validates :siren, presence: true

  validates :siren,            format: { allow_blank: true, with: SIREN_REGEXP }
  validates :code_departement, format: { allow_blank: true, with: CODE_DEPARTEMENT_REGEXP }

  validates :siren, uniqueness: { unless: :skip_uniqueness_validation_of_siren? }

  # Scopes
  # ----------------------------------------------------------------------------
  scope :search, lambda { |input|
    advanced_search(
      input,
      name:             ->(value) { match(:name, value) },
      siren:            ->(value) { where(siren: value) },
      code_departement: ->(value) { where(code_departement: value) },
      departement_name: ->(value) { left_joins(:departement).merge(Departement.match(:name, value)) },
      region_name:      ->(value) { left_joins(:region).merge(Region.match(:name, value)) }
    )
  }

  scope :order_by_param, lambda { |input|
    advanced_order(
      input,
      epci:         ->(direction) { unaccent_order(:name, direction) },
      departement:  ->(direction) { order(code_departement: direction) }
    )
  }

  scope :order_by_score, lambda { |input|
    scored_order(:name, input)
  }

  # Callbacks
  # ----------------------------------------------------------------------------
  before_validation :clean_empty_code_departement

  def clean_empty_code_departement
    self.code_departement = nil if code_departement.blank?
  end

  # Other associations
  # ----------------------------------------------------------------------------
  def on_territory_collectivities
    territories = [self]
    territories << communes
    territories << Departement.joins(:communes).merge(communes)

    Collectivity.kept.where(territory: territories)
  end

  # Counters cached
  # ----------------------------------------------------------------------------
  def self.reset_all_counters
    communes       = Commune.where(%("communes"."siren_epci" = "epcis"."siren"))
    departements   = Departement.joins(:communes).merge(communes)

    collectivities = Collectivity.kept.where(<<~SQL.squish, communes.select(:id), departements.select(:id))
      "collectivities"."territory_type" = 'EPCI'        AND "collectivities"."territory_id" = "epcis"."id" OR
      "collectivities"."territory_type" = 'Commune'     AND "collectivities"."territory_id" IN (?) OR
      "collectivities"."territory_type" = 'Departement' AND "collectivities"."territory_id" IN (?)
    SQL

    update_all_counters(
      communes_count:       communes,
      collectivities_count: collectivities
    )
  end
end
