# frozen_string_literal: true

# == Schema Information
#
# Table name: ddfips
#
#  id                        :uuid             not null, primary key
#  name                      :string           not null
#  code_departement          :string           not null
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  discarded_at              :datetime
#  contact_first_name        :string
#  contact_last_name         :string
#  contact_email             :string
#  contact_phone             :string
#  domain_restriction        :string
#  allow_2fa_via_email       :boolean          default(FALSE), not null
#  auto_assign_reports       :boolean          default(FALSE), not null
#  users_count               :integer          default(0), not null
#  collectivities_count      :integer          default(0), not null
#  offices_count             :integer          default(0), not null
#  reports_transmitted_count :integer          default(0), not null
#  reports_unassigned_count  :integer          default(0), not null
#  reports_accepted_count    :integer          default(0), not null
#  reports_rejected_count    :integer          default(0), not null
#  reports_approved_count    :integer          default(0), not null
#  reports_canceled_count    :integer          default(0), not null
#  reports_returned_count    :integer          default(0), not null
#  ip_ranges                 :text             default([]), not null, is an Array
#
# Indexes
#
#  index_ddfips_on_code_departement  (code_departement)
#  index_ddfips_on_discarded_at      (discarded_at)
#  index_ddfips_on_name              (name) UNIQUE WHERE (discarded_at IS NULL)
#
# Foreign Keys
#
#  fk_rails_...  (code_departement => departements.code_departement)
#
class DDFIP < ApplicationRecord
  audited

  # Associations
  # ----------------------------------------------------------------------------
  belongs_to :departement, primary_key: :code_departement, foreign_key: :code_departement, inverse_of: :ddfips

  has_many :epcis,    primary_key: :code_departement, foreign_key: :code_departement, inverse_of: false, dependent: false
  has_many :communes, primary_key: :code_departement, foreign_key: :code_departement, inverse_of: false, dependent: false
  has_many :reports, dependent: false
  has_many :packages, dependent: false
  has_one  :region, through: :departement

  has_many :users, as: :organization, dependent: :delete_all

  has_many :offices,   dependent: false
  has_many :workshops, dependent: false

  # Validations
  # ----------------------------------------------------------------------------
  validates :name,             presence: true
  validates :code_departement, presence: true

  validates :code_departement,   format: { allow_blank: true, with: CODE_DEPARTEMENT_REGEXP }
  validates :contact_email,      format: { allow_blank: true, with: EMAIL_REGEXP }
  validates :contact_phone,      format: { allow_blank: true, with: PHONE_REGEXP }
  validates :domain_restriction, format: { allow_blank: true, with: DOMAIN_REGEXP }

  validates :name, uniqueness: {
    case_sensitive: false,
    conditions: -> { kept },
    unless: :skip_uniqueness_validation_of_name?
  }

  normalizes :ip_ranges, with: ->(ip_ranges) { ip_ranges.reject(&:empty?).uniq }
  validates :ip_ranges, ip_address: { allow_blank: true }

  # Scopes
  # ----------------------------------------------------------------------------
  scope :covering, lambda { |reports|
    if reports.is_a?(ActiveRecord::Relation)
      distinct.joins(communes: :reports).merge(reports)
    else
      codes    = reports.pluck(:code_insee).uniq
      communes = Commune.where(code_insee: codes)
      distinct.joins(:communes).merge(communes)
    end
  }

  # Scopes: searches
  # ----------------------------------------------------------------------------
  scope :search, lambda { |input|
    advanced_search(input, scopes: {
      name:             ->(value) { match(:name, value) },
      code_departement: ->(value) { where(code_departement: value) },
      departement_name: ->(value) { left_joins(:departement).merge(Departement.search(name: value)) },
      region_name:      ->(value) { left_joins(:region).merge(Region.search(name: value)) }
    })
  }

  scope :autocomplete, lambda { |input|
    advanced_search(input, scopes: {
      name:             ->(value) { match(:name, value) },
      code_departement: ->(value) { where(code_departement: value) }
    })
  }

  # Scopes: orders
  # ----------------------------------------------------------------------------
  scope :order_by_param, lambda { |input|
    advanced_order(
      input,
      name:        ->(direction) { order_by_name(direction) },
      departement: ->(direction) { order_by_departement(direction) },
      region:      ->(direction) { order_by_region(direction) }
    )
  }

  scope :order_by_score, lambda { |input|
    scored_order(:name, input)
  }

  scope :order_by_name,        ->(direction = :asc) { unaccent_order(:name, direction) }
  scope :order_by_departement, ->(direction = :asc) { order(code_departement: direction) }

  scope :order_by_region, lambda { |direction = :asc|
    left_joins(:departement).merge(Departement.order_by_region(direction))
  }

  # Other associations
  # ----------------------------------------------------------------------------
  def on_territory_collectivities
    territories = []
    territories << communes
    territories << EPCI.joins(:communes).merge(communes)
    territories << Departement.where(code_departement: code_departement)

    Collectivity.kept.where(territory: territories)
  end

  # Updates methods
  # ----------------------------------------------------------------------------
  def self.reset_all_counters
    connection.select_value("SELECT reset_all_ddfips_counters()")
  end
end
