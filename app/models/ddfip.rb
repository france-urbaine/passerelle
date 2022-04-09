# frozen_string_literal: true

# == Schema Information
#
# Table name: ddfips
#
#  id               :uuid             not null, primary key
#  name             :string           not null
#  code_departement :string           not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  discarded_at     :datetime
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
  belongs_to :departement, primary_key: :code_departement, foreign_key: :code_departement, inverse_of: :ddfips, optional: true

  has_many :users, as: :organization, dependent: :delete_all

  # Validations
  # ----------------------------------------------------------------------------
  validates :name,             presence: true
  validates :code_departement, presence: true
  validates :code_departement, format: { allow_blank: true, with: CODE_DEPARTEMENT_REGEXP }

  # FYI: About uniqueness validations, case insensitivity and accents:
  # You should read ./docs/uniqueness_validations_and_accents.md
  validates :name, uniqueness: { case_sensitive: false, unless: :skip_uniqueness_validation_of_name? }
end
