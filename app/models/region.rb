# frozen_string_literal: true

# == Schema Information
#
# Table name: regions
#
#  id          :uuid             not null, primary key
#  name        :string           not null
#  code_region :string           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
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

  has_many :communes,       through: :departements
  has_many :epcis,          through: :departements
  has_many :ddfips,         through: :departements
  has_many :collectivities, through: :departements

  # Validations
  # ----------------------------------------------------------------------------
  validates :name,        presence: true
  validates :code_region, presence: true

  validates :code_region, format: { allow_blank: true, with: CODE_REGION_REGEXP }
  validates :code_region, uniqueness: { unless: :skip_uniqueness_validation_of_code_region? }
end
