# frozen_string_literal: true

# == Schema Information
#
# Table name: collectivities
#
#  id                         :uuid             not null, primary key
#  territory_type             :enum             not null
#  territory_id               :uuid             not null
#  publisher_id               :uuid
#  name                       :string           not null
#  siren                      :string           not null
#  contact_first_name         :string
#  contact_last_name          :string
#  contact_email              :string
#  contact_phone              :string
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  approved_at                :datetime
#  disapproved_at             :datetime
#  desactivated_at            :datetime
#  discarded_at               :datetime
#  domain_restriction         :string
#  allow_2fa_via_email        :boolean          default(FALSE), not null
#  allow_publisher_management :boolean          default(FALSE), not null
#  users_count                :integer          default(0), not null
#  reports_transmitted_count  :integer          default(0), not null
#  reports_accepted_count     :integer          default(0), not null
#  reports_rejected_count     :integer          default(0), not null
#  reports_approved_count     :integer          default(0), not null
#  reports_canceled_count     :integer          default(0), not null
#  reports_returned_count     :integer          default(0), not null
#
# Indexes
#
#  index_collectivities_on_discarded_at  (discarded_at)
#  index_collectivities_on_name          (name) UNIQUE WHERE (discarded_at IS NULL)
#  index_collectivities_on_publisher_id  (publisher_id)
#  index_collectivities_on_siren         (siren) UNIQUE WHERE (discarded_at IS NULL)
#  index_collectivities_on_territory     (territory_type,territory_id)
#
# Foreign Keys
#
#  fk_rails_...  (publisher_id => publishers.id) ON DELETE => nullify
#
class Collectivity < ApplicationRecord
  audited

  # Associations
  # ----------------------------------------------------------------------------
  belongs_to :territory, polymorphic: true, inverse_of: :registered_collectivity
  belongs_to :publisher, optional: true

  has_many :users, as: :organization, dependent: :delete_all

  has_many :transmissions, dependent: false
  has_many :packages, dependent: false
  has_many :reports, dependent: false

  # Validations
  # ----------------------------------------------------------------------------
  validates :name,  presence: true
  validates :siren, presence: true

  validates :siren,              format: { allow_blank: true, with: SIREN_REGEXP }
  validates :contact_email,      format: { allow_blank: true, with: EMAIL_REGEXP }
  validates :contact_phone,      format: { allow_blank: true, with: PHONE_REGEXP }
  validates :domain_restriction, format: { allow_blank: true, with: DOMAIN_REGEXP }

  validates :territory_type, inclusion: { in: %w[Commune EPCI Departement Region] }

  validates :name, uniqueness: {
    case_sensitive: false,
    conditions: -> { kept },
    unless: :skip_uniqueness_validation_of_name?
  }

  validates :siren, uniqueness: {
    case_sensitive: false,
    conditions: -> { kept },
    unless: :skip_uniqueness_validation_of_siren?
  }

  # Callbacks
  # ----------------------------------------------------------------------------
  before_validation :normalize_contact_phone

  def normalize_contact_phone
    self.contact_phone = contact_phone&.delete(" ")
  end

  # Scopes
  # ----------------------------------------------------------------------------
  scope :communes,     -> { where(territory_type: "Commune") }
  scope :epcis,        -> { where(territory_type: "EPCI") }
  scope :departements, -> { where(territory_type: "Departement") }
  scope :regions,      -> { where(territory_type: "Region") }

  scope :orphans,      -> { where(publisher_id: nil) }
  scope :owned_by, ->(publisher) { where(publisher: publisher) }

  # Scopes: searches
  # ----------------------------------------------------------------------------
  scope :search, lambda { |input|
    advanced_search(input, scopes: {
      name:      ->(value) { match(:name, value) },
      siren:     ->(value) { where(siren: value) },
      publisher: ->(value) { left_joins(:publisher).merge(Publisher.search(name: value)) }
    })
  }

  scope :autocomplete, lambda { |input|
    advanced_search(input, scopes: {
      name:  ->(value) { match(:name, value) },
      siren: ->(value) { where(siren: value) }
    })
  }

  # Scopes: orders
  # ----------------------------------------------------------------------------
  scope :order_by_param, lambda { |input|
    advanced_order(
      input,
      name:      ->(direction) { order_by_name(direction) },
      siren:     ->(direction) { order_by_siren(direction) },
      publisher: ->(direction) { order_by_publisher(direction) }
    )
  }

  scope :order_by_score, lambda { |input|
    scored_order(:name, input)
  }

  scope :order_by_name,      ->(direction = :asc) { unaccent_order(:name, direction) }
  scope :order_by_siren,     ->(direction = :asc) { order(siren: direction) }
  scope :order_by_publisher, ->(direction = :asc) { left_joins(:publisher).merge(Publisher.order_by_name(direction)) }

  # Predicates
  # ----------------------------------------------------------------------------
  def orphan?
    !(publisher_id? || (new_record? && publisher))
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

  def region?
    territory_type == "Region"
  end

  # Other associations
  # ----------------------------------------------------------------------------
  def reportable_communes
    known_communes =
      case territory_type
      when "Commune"     then Commune.where(id: territory_id)
      when "EPCI"        then Commune.joins(:epci).merge(EPCI.where(id: territory_id))
      when "Departement" then Commune.joins(:departement).merge(Departement.where(id: territory_id))
      when "Region"      then Commune.joins(:region).merge(Region.where(id: territory_id))
      end

    Commune.with_arrondissements_instead_of_communes(known_communes)
  end

  def assigned_offices
    Office.kept.distinct.joins(:communes).merge(reportable_communes)
  end

  # Updates methods
  # ----------------------------------------------------------------------------
  def self.reset_all_counters
    connection.select_value("SELECT reset_all_collectivities_counters()")
  end
end
