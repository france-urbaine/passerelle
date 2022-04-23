# frozen_string_literal: true

# == Schema Information
#
# Table name: communes
#
#  id                   :uuid             not null, primary key
#  name                 :string           not null
#  code_insee           :string           not null
#  code_departement     :string           not null
#  siren_epci           :string
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  collectivities_count :integer          default(0), not null
#
# Indexes
#
#  index_communes_on_code_departement  (code_departement)
#  index_communes_on_code_insee        (code_insee) UNIQUE
#  index_communes_on_siren_epci        (siren_epci)
#
class Commune < ApplicationRecord
  self.implicit_order_column = :code_insee

  # Associations
  # ----------------------------------------------------------------------------
  belongs_to :departement, primary_key: :code_departement, foreign_key: :code_departement, inverse_of: :communes, counter_cache: true
  belongs_to :epci, primary_key: :siren, foreign_key: :siren_epci, inverse_of: :communes, optional: true, counter_cache: true

  has_one :region, through: :departement

  has_one :registered_collectivity, class_name: "Collectivity", as: :territory, dependent: false

  # Validations
  # ----------------------------------------------------------------------------
  validates :name,             presence: true
  validates :code_insee,       presence: true
  validates :code_departement, presence: true

  validates :code_insee,       format: { allow_blank: true, with: CODE_INSEE_REGEXP }
  validates :code_departement, format: { allow_blank: true, with: CODE_DEPARTEMENT_REGEXP }
  validates :siren_epci,       format: { allow_blank: true, with: SIREN_REGEXP }

  validates :code_insee, uniqueness: { unless: :skip_uniqueness_validation_of_code_insee? }

  # Scopes
  # ----------------------------------------------------------------------------
  scope :search, lambda { |input|
    advanced_search(
      input,
      name:             ->(value) { match(:name, value) },
      code_insee:       ->(value) { where(code_insee: value) },
      siren_epci:       ->(value) { where(siren_epci: value) },
      code_departement: ->(value) { where(code_departement: value) },
      epci_name:        ->(value) { left_joins(:epci).merge(EPCI.match(:name, value)) },
      departement_name: ->(value) { left_joins(:departement).merge(Departement.match(:name, value)) },
      region_name:      ->(value) { left_joins(:region).merge(Region.match(:name, value)) }
    )
  }

  scope :order_by_param, lambda { |input|
    advanced_order(
      input,
      commune:      ->(direction) { unaccent_order(:name, direction) },
      departement:  ->(direction) { order(code_departement: direction) },
      epci:         ->(direction) { left_joins(:epci).merge(EPCI.unaccent_order(:name, direction)) }
    )
  }

  scope :order_by_score, lambda { |input|
    scored_order(:name, input)
  }

  # Callbacks
  # ----------------------------------------------------------------------------
  before_validation :clean_attributes

  def clean_attributes
    self.siren_epci = nil if siren_epci.blank?
  end

  # Other associations
  # ----------------------------------------------------------------------------
  def on_territory_collectivities
    territories = [self]
    territories << EPCI.where(siren: siren_epci) if siren_epci
    territories << Departement.where(code_departement: code_departement)

    Collectivity.kept.where(territory: territories)
  end

  # Counters cached
  # ----------------------------------------------------------------------------
  def self.reset_all_counters
    epcis          = EPCI.where(%("epcis"."siren" = "communes"."siren_epci"))
    departements   = Departement.where(%("departements"."code_departement" = "communes"."code_departement"))
    collectivities = Collectivity.kept.where(<<~SQL.squish, epcis.select(:id), departements.select(:id))
      "collectivities"."territory_type" = 'Commune'     AND "collectivities"."territory_id" = "communes"."id" OR
      "collectivities"."territory_type" = 'EPCI'        AND "collectivities"."territory_id" IN (?) OR
      "collectivities"."territory_type" = 'Departement' AND "collectivities"."territory_id" IN (?)
    SQL

    update_all_counters(collectivities_count: collectivities)
  end
end