# frozen_string_literal: true

# == Schema Information
#
# Table name: departements
#
#  id               :uuid             not null, primary key
#  name             :string           not null
#  code_departement :string           not null
#  code_region      :string           not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
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
  belongs_to :region, primary_key: :code_region, foreign_key: :code_region, inverse_of: :departements

  has_many :communes, primary_key: :code_departement, foreign_key: :code_departement, inverse_of: :departement, dependent: false
  has_many :epcis,    primary_key: :code_departement, foreign_key: :code_departement, inverse_of: :departement, dependent: false
  has_many :ddfips,   primary_key: :code_departement, foreign_key: :code_departement, inverse_of: :departement, dependent: false

  has_many :collectivities, as: :territory, dependent: false

  # Validations
  # ----------------------------------------------------------------------------
  validates :name,             presence: true
  validates :code_departement, presence: true
  validates :code_region,      presence: true

  validates :code_departement, format: { allow_blank: true, with: CODE_DEPARTEMENT_REGEXP }
  validates :code_region,      format: { allow_blank: true, with: CODE_REGION_REGEXP }

  validates :code_departement, uniqueness: { unless: :skip_uniqueness_validation_of_code_departement? }
end
