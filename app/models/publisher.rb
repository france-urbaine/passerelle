# frozen_string_literal: true

# == Schema Information
#
# Table name: publishers
#
#  id                   :uuid             not null, primary key
#  name                 :string           not null
#  siren                :string           not null
#  email                :string
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  discarded_at         :datetime
#  users_count          :integer          default(0), not null
#  collectivities_count :integer          default(0), not null
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

  validates :name,  uniqueness: {
    case_sensitive: false,
    conditions: -> { kept },
    unless: :skip_uniqueness_validation_of_name?
  }

  validates :siren, uniqueness: {
    case_sensitive: false,
    conditions: -> { kept },
    unless: :skip_uniqueness_validation_of_siren?
  }

  # Scopes
  # ----------------------------------------------------------------------------
  scope :search, lambda { |input|
    advanced_search(
      input,
      name:  ->(value) { match(:name, value) },
      siren: ->(value) { where(siren: value) }
    )
  }

  scope :order_by_param, lambda { |input|
    advanced_order(
      input,
      name:  ->(direction) { unaccent_order(:name, direction) },
      siren: ->(direction) { order(siren: direction) }
    )
  }

  scope :order_by_score, lambda { |input|
    scored_order(:name, input)
  }

  # Counters cached
  # ----------------------------------------------------------------------------
  def self.reset_all_counters
    connection.select_value("SELECT reset_all_publishers_counters()")
  end
end
