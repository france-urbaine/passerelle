# frozen_string_literal: true

# == Schema Information
#
# Table name: collectivities
#
#  id                 :uuid             not null, primary key
#  territory_type     :string           not null
#  territory_id       :uuid             not null
#  publisher_id       :uuid
#  name               :string           not null
#  siren              :string           not null
#  contact_first_name :string
#  contact_last_name  :string
#  contact_email      :string
#  contact_phone      :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  approved_at        :datetime
#  disapproved_at     :datetime
#  desactivated_at    :datetime
#  discarded_at       :datetime
#  users_count        :integer          default(0), not null
#
# Indexes
#
#  index_collectivities_on_discarded_at  (discarded_at)
#  index_collectivities_on_name          (name) UNIQUE WHERE (discarded_at IS NULL)
#  index_collectivities_on_publisher_id  (publisher_id)
#  index_collectivities_on_siren         (siren) UNIQUE WHERE (discarded_at IS NULL)
#  index_collectivities_on_territory     (territory_type,territory_id)
#
class Collectivity < ApplicationRecord
  # Associations
  # ----------------------------------------------------------------------------
  belongs_to :territory, polymorphic: true, inverse_of: :registered_collectivity, counter_cache: true
  belongs_to :publisher, optional: true, counter_cache: true

  has_many :users, as: :organization, dependent: :delete_all

  # Validations
  # ----------------------------------------------------------------------------
  validates :name,  presence: true
  validates :siren, presence: true

  validates :siren,         format: { allow_blank: true, with: SIREN_REGEXP }
  validates :contact_email, format: { allow_blank: true, with: EMAIL_REGEXP }
  validates :contact_phone, format: { allow_blank: true, with: PHONE_REGEXP }
  validates :territory_type, inclusion: { in: %w[Commune EPCI Departement] }

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
  scope :orphans,      -> { where(publisher_id: nil) }
  scope :communes,     -> { where(territory_type: "Commune") }
  scope :epcis,        -> { where(territory_type: "EPCI") }
  scope :departements, -> { where(territory_type: "Departement") }

  scope :search, lambda { |input|
    advanced_search(
      input,
      name:           ->(value) { match(:name, value) },
      siren:          ->(value) { where(siren: value) },
      publisher_name: ->(value) { left_joins(:publisher).merge(Publisher.where(name: value)) }
    )
  }

  # Callbacks
  # ----------------------------------------------------------------------------
  before_validation :clean_attributes

  def clean_attributes
    self.contact_phone = contact_phone&.delete(" ")
  end

  # Predicates
  # ----------------------------------------------------------------------------
  def orphan?
    publisher_id.nil?
  end

  def commune?
    territory_type == "Commune"
  end

  def epci?
    territory_type == "EPCI"
  end

  def departement?
    territory_type == "Departement"
  end

  # Counters cached
  # ----------------------------------------------------------------------------
  def self.reset_all_counters
    users = User.where(<<~SQL.squish)
      "users"."organization_type" = 'Collectivity' AND "users"."organization_id" = "collectivities"."id"
    SQL

    update_all_counters(users_count: users)
  end
end
