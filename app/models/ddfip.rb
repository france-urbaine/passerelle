# frozen_string_literal: true

# == Schema Information
#
# Table name: ddfips
#
#  id                   :uuid             not null, primary key
#  name                 :string           not null
#  code_departement     :string           not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  discarded_at         :datetime
#  users_count          :integer          default(0), not null
#  collectivities_count :integer          default(0), not null
#
# Indexes
#
#  index_ddfips_on_code_departement  (code_departement)
#  index_ddfips_on_discarded_at      (discarded_at)
#  index_ddfips_on_name              (name) UNIQUE WHERE (discarded_at IS NULL)
#
class DDFIP < ApplicationRecord
  # Associations
  # ----------------------------------------------------------------------------
  belongs_to :departement, primary_key: :code_departement, foreign_key: :code_departement, inverse_of: :ddfips, counter_cache: true

  has_many :epcis,    primary_key: :code_departement, foreign_key: :code_departement, inverse_of: false, dependent: false
  has_many :communes, primary_key: :code_departement, foreign_key: :code_departement, inverse_of: false, dependent: false
  has_one  :region, through: :departement

  has_many :users, as: :organization, dependent: :delete_all

  # Validations
  # ----------------------------------------------------------------------------
  validates :name,             presence: true
  validates :code_departement, presence: true
  validates :code_departement, format: { allow_blank: true, with: CODE_DEPARTEMENT_REGEXP }

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
      code_departement: ->(value) { where(code_departement: value) }
    )
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

  # Counters cached
  # ----------------------------------------------------------------------------
  def self.reset_all_counters
    users = User.where(<<~SQL.squish)
      "users"."organization_type" = 'DDFIP' AND "users"."organization_id" = "ddfips"."id"
    SQL

    communes     = Commune.where(%("communes"."code_departement" = "ddfips"."code_departement"))
    departements = Departement.where(%("departements"."code_departement" = "ddfips"."code_departement"))
    epcis        = EPCI.joins(:communes).merge(communes)

    territory_ids  = [communes.select(:id), epcis.select(:id), departements.select(:id)]
    collectivities = Collectivity.kept.where(<<~SQL.squish, *territory_ids)
      "collectivities"."territory_type" = 'Commune'     AND "collectivities"."territory_id" IN (?) OR
      "collectivities"."territory_type" = 'EPCI'        AND "collectivities"."territory_id" IN (?) OR
      "collectivities"."territory_type" = 'Departement' AND "collectivities"."territory_id" IN (?)
    SQL

    update_all_counters(
      users_count:          users,
      collectivities_count: collectivities
    )
  end
end
