# frozen_string_literal: true

# == Schema Information
#
# Table name: communes
#
#  id               :uuid             not null, primary key
#  name             :string           not null
#  code_insee       :string           not null
#  code_departement :string           not null
#  siren_epci       :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
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
  belongs_to :departement, primary_key: :code_departement, foreign_key: :code_departement, inverse_of: :communes
  belongs_to :epci, primary_key: :siren, foreign_key: :siren_epci, inverse_of: :communes, optional: true

  has_many :collectivities, as: :territory, dependent: false

  # Validations
  # ----------------------------------------------------------------------------
  validates :name,             presence: true
  validates :code_insee,       presence: true
  validates :code_departement, presence: true

  validates :code_insee,       format: { allow_blank: true, with: CODE_INSEE_REGEXP }
  validates :code_departement, format: { allow_blank: true, with: CODE_DEPARTEMENT_REGEXP }
  validates :siren_epci,       format: { allow_blank: true, with: SIREN_REGEXP }

  validates :code_insee, uniqueness: { unless: :skip_uniqueness_validation_of_code_insee? }

  # Callbacks
  # ----------------------------------------------------------------------------
  before_validation :clean_attributes

  def clean_attributes
    self.siren_epci = nil if siren_epci.blank?
  end
end
