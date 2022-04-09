# frozen_string_literal: true

# == Schema Information
#
# Table name: publishers
#
#  id           :uuid             not null, primary key
#  name         :string           not null
#  siren        :string           not null
#  email        :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  discarded_at :datetime
#
# Indexes
#
#  index_publishers_on_discarded_at  (discarded_at)
#  index_publishers_on_name          (name) UNIQUE WHERE (discarded_at IS NULL)
#  index_publishers_on_siren         (siren) UNIQUE WHERE (discarded_at IS NULL)
#
class Publisher < ApplicationRecord
  # Associations
  # ----------------------------------------------------------------------------
  has_many :users, as: :organization, dependent: :delete_all
  has_many :collectivities, dependent: :delete_all

  # Validations
  # ----------------------------------------------------------------------------
  validates :name,  presence: true
  validates :siren, presence: true

  validates :siren, format: { allow_blank: true, with: SIREN_REGEXP }
  validates :email, format: { allow_blank: true, with: EMAIL_REGEXP }

  # FYI: About uniqueness validations, case insensitivity and accents:
  # You should read ./docs/uniqueness_validations_and_accents.md
  validates :name,  uniqueness: { case_sensitive: false, unless: :skip_uniqueness_validation_of_name? }
  validates :siren, uniqueness: { case_sensitive: false, unless: :skip_uniqueness_validation_of_siren? }
end
