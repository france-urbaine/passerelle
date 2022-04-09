# frozen_string_literal: true

# == Schema Information
#
# Table name: epcis
#
#  id               :uuid             not null, primary key
#  name             :string           not null
#  siren            :string           not null
#  code_departement :string
#  nature           :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
# Indexes
#
#  index_epcis_on_code_departement  (code_departement)
#  index_epcis_on_siren             (siren) UNIQUE
#
class EPCI < ApplicationRecord
  self.implicit_order_column = :siren

  # Associations
  # ----------------------------------------------------------------------------
  belongs_to :departement, primary_key: :code_departement, foreign_key: :code_departement, inverse_of: :epcis, optional: true

  has_many :communes, primary_key: :siren, foreign_key: :siren_epci, inverse_of: :epci, dependent: false
  has_many :collectivities, as: :territory, dependent: false

  has_one :region, through: :departement

  # Validations
  # ----------------------------------------------------------------------------
  validates :name,  presence: true
  validates :siren, presence: true

  validates :siren,            format: { allow_blank: true, with: SIREN_REGEXP }
  validates :code_departement, format: { allow_blank: true, with: CODE_DEPARTEMENT_REGEXP }

  validates :siren, uniqueness: { unless: :skip_uniqueness_validation_of_siren? }

  # Callbacks
  # ----------------------------------------------------------------------------
  before_validation :clean_empty_code_departement

  def clean_empty_code_departement
    self.code_departement = nil if code_departement.blank?
  end
end
