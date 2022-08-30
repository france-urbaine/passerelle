# frozen_string_literal: true

# == Schema Information
#
# Table name: regions
#
#  id                   :uuid             not null, primary key
#  name                 :string           not null
#  code_region          :string           not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  departements_count   :integer          default(0), not null
#  epcis_count          :integer          default(0), not null
#  communes_count       :integer          default(0), not null
#  ddfips_count         :integer          default(0), not null
#  collectivities_count :integer          default(0), not null
#  qualified_name       :string
#
# Indexes
#
#  index_regions_on_code_region  (code_region) UNIQUE
#
class Region < ApplicationRecord
  self.implicit_order_column = :code_region

  # Associations
  # ----------------------------------------------------------------------------
  has_many :departements, primary_key: :code_region, foreign_key: :code_region, inverse_of: :region, dependent: false

  has_many :communes, through: :departements
  has_many :epcis,    through: :departements
  has_many :ddfips,   through: :departements

  has_one :registered_collectivity, class_name: "Collectivity", as: :territory, dependent: false

  # Validations
  # ----------------------------------------------------------------------------
  validates :name,        presence: true
  validates :code_region, presence: true

  validates :code_region, format: { allow_blank: true, with: CODE_REGION_REGEXP }
  validates :code_region, uniqueness: { unless: :skip_uniqueness_validation_of_code_region? }

  # Callbacks
  # ----------------------------------------------------------------------------
  before_save :generate_qualified_name, if: :qualified_name_need_to_be_regenerated?

  def qualified_name_need_to_be_regenerated?
    qualified_name.blank? || (name_changed? && !qualified_name_changed?)
  end

  def generate_qualified_name
    self.qualified_name = "Département de #{name}"
  end

  # Scopes
  # ----------------------------------------------------------------------------
  scope :search, lambda { |input|
    advanced_search(
      input,
      name:        ->(value) { match(:name, value) },
      code_region: ->(value) { where(code_region: value) }
    )
  }

  scope :order_by_param, lambda { |input|
    advanced_order(
      input,
      region: ->(direction) { order(code_region: direction) }
    )
  }

  scope :order_by_score, lambda { |input|
    scored_order(:name, input)
  }

  # Other associations
  # ----------------------------------------------------------------------------
  def on_territory_collectivities
    territories = []
    territories << departements
    territories << communes
    territories << EPCI.joins(:communes).merge(communes)

    Collectivity.kept.where(territory: territories)
  end

  # Counters cached
  # ----------------------------------------------------------------------------
  def self.reset_all_counters
    connection.select_value("SELECT reset_all_regions_counters()")
  end
end
