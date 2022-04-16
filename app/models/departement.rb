# frozen_string_literal: true

# == Schema Information
#
# Table name: departements
#
#  id                   :uuid             not null, primary key
#  name                 :string           not null
#  code_departement     :string           not null
#  code_region          :string           not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  epcis_count          :integer          default(0), not null
#  communes_count       :integer          default(0), not null
#  ddfips_count         :integer          default(0), not null
#  collectivities_count :integer          default(0), not null
#
# Indexes
#
#  index_departements_on_code_departement  (code_departement) UNIQUE
#  index_departements_on_code_region       (code_region)
#
class Departement < ApplicationRecord
  self.implicit_order_column = :code_departement

  # Associations
  # ----------------------------------------------------------------------------
  belongs_to :region, primary_key: :code_region, foreign_key: :code_region, inverse_of: :departements, counter_cache: true

  has_many :communes, primary_key: :code_departement, foreign_key: :code_departement, inverse_of: :departement, dependent: false
  has_many :epcis,    primary_key: :code_departement, foreign_key: :code_departement, inverse_of: :departement, dependent: false
  has_many :ddfips,   primary_key: :code_departement, foreign_key: :code_departement, inverse_of: :departement, dependent: false

  has_one :registered_collectivity, class_name: "Collectivity", as: :territory, dependent: false

  # Validations
  # ----------------------------------------------------------------------------
  validates :name,             presence: true
  validates :code_departement, presence: true
  validates :code_region,      presence: true

  validates :code_departement, format: { allow_blank: true, with: CODE_DEPARTEMENT_REGEXP }
  validates :code_region,      format: { allow_blank: true, with: CODE_REGION_REGEXP }

  validates :code_departement, uniqueness: { unless: :skip_uniqueness_validation_of_code_departement? }

  # Scopes
  # ----------------------------------------------------------------------------
  scope :search, lambda { |input|
    advanced_search(
      input,
      name:             ->(value) { match(:name, value) },
      code_departement: ->(value) { where(code_departement: value) },
      region_name:      ->(value) { left_joins(:region).merge(Region.match(:name, value)) }
    )
  }

  scope :order_by_param, lambda { |input|
    advanced_order(
      input,
      departement: ->(direction) { order(code_departement: direction) },
      region:      ->(direction) { order(code_region: direction) }
    )
  }

  scope :order_by_score, lambda { |input|
    scored_order(:name, input)
  }

  # Other associations
  # ----------------------------------------------------------------------------
  def on_territory_collectivities
    territories = [self]
    territories << communes
    territories << EPCI.joins(:communes).merge(communes)

    Collectivity.kept.where(territory: territories)
  end

  # Counters cached
  # ----------------------------------------------------------------------------
  def self.reset_all_counters
    communes       = Commune.where(%("communes"."code_departement" = "departements"."code_departement"))
    epcis          = EPCI.where(%("epcis"."code_departement" = "departements"."code_departement"))
    ddfips         = DDFIP.where(%("ddfips"."code_departement" = "departements"."code_departement"))

    communes_epcis = EPCI.joins(:communes).merge(communes)
    collectivities = Collectivity.kept.where(<<~SQL.squish, communes.select(:id), communes_epcis.select(:id))
      "collectivities"."territory_type" = 'Departement' AND "collectivities"."territory_id" = "departements"."id" OR
      "collectivities"."territory_type" = 'Commune'     AND "collectivities"."territory_id" IN (?) OR
      "collectivities"."territory_type" = 'EPCI'        AND "collectivities"."territory_id" IN (?)
    SQL

    update_all_counters(
      epcis_count:          epcis,
      communes_count:       communes,
      ddfips_count:         ddfips,
      collectivities_count: collectivities
    )
  end
end
