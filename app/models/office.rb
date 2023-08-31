# frozen_string_literal: true

# == Schema Information
#
# Table name: offices
#
#  id                     :uuid             not null, primary key
#  ddfip_id               :uuid             not null
#  name                   :string           not null
#  competences            :enum             not null, is an Array
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  discarded_at           :datetime
#  users_count            :integer          default(0), not null
#  communes_count         :integer          default(0), not null
#  reports_count          :integer          default(0), not null
#  reports_approved_count :integer          default(0), not null
#  reports_rejected_count :integer          default(0), not null
#  reports_debated_count  :integer          default(0), not null
#  reports_pending_count  :integer          default(0), not null
#
# Indexes
#
#  index_offices_on_ddfip_id           (ddfip_id)
#  index_offices_on_ddfip_id_and_name  (ddfip_id,name) UNIQUE WHERE (discarded_at IS NULL)
#  index_offices_on_discarded_at       (discarded_at)
#
# Foreign Keys
#
#  fk_rails_...  (ddfip_id => ddfips.id) ON DELETE => cascade
#
class Office < ApplicationRecord
  # Associations
  # ----------------------------------------------------------------------------
  belongs_to :ddfip

  has_many :office_users,    dependent: false
  has_many :office_communes, dependent: false

  has_many :users,    through: :office_users
  has_many :communes, through: :office_communes

  has_one  :departement, through: :ddfip
  has_many :departement_communes, through: :departement, source: :communes

  # Validations
  # ----------------------------------------------------------------------------
  COMPETENCES = %w[
    evaluation_local_habitation
    evaluation_local_professionnel
    creation_local_habitation
    creation_local_professionnel
    occupation_local_habitation
    occupation_local_professionnel
  ].freeze

  validates :name,        presence: true
  validates :competences, array: true, inclusion: { in: COMPETENCES, allow_blank: true }

  validates :name, uniqueness: {
    case_sensitive: false,
    conditions: -> { kept },
    scope: :ddfip_id,
    unless: :skip_uniqueness_validation_of_name?
  }

  # Scopes
  # ----------------------------------------------------------------------------
  scope :owned_by, ->(ddfip) { where(ddfip: ddfip) }

  scope :search, lambda { |input|
    advanced_search(
      input,
      name:             ->(value) { match(:name, value) },
      ddfip_name:       ->(value) { left_joins(:ddfip).merge(DDFIP.match(:name, value)) },
      code_departement: ->(value) { left_joins(:ddfip).merge(DDFIP.where(code_departement: value)) }
    )
  }

  scope :autocomplete, lambda { |input|
    advanced_search(
      input,
      name: ->(value) { match(:name, value) }
    )
  }

  scope :order_by_param, lambda { |input|
    advanced_order(
      input,
      name:        ->(direction) { unaccent_order(:name, direction) },
      ddfip:       ->(direction) { left_joins(:ddfip).merge(DDFIP.unaccent_order(:name, direction)) },
      competences: ->(direction) { order(competences: direction) }
    )
  }

  scope :order_by_score, lambda { |input|
    scored_order(:name, input)
  }

  # Other associations
  # ----------------------------------------------------------------------------
  def on_territory_collectivities
    territories = []
    territories << communes
    territories << EPCI.joins(:communes).merge(communes)
    territories << Departement.joins(:communes).merge(communes)

    Collectivity.kept.where(territory: territories)
  end

  # Updates methods
  # ----------------------------------------------------------------------------
  # When no selection is made for a collection of checkboxes, most web browsers
  # wont't send any value.
  #
  # `collection_check_boxes` adds a blank value to the array:
  #   ["", "evaluation_local_habitation"]
  #
  def competences=(value)
    value.compact_blank! if value.is_a?(Array)
    super(value)
  end

  def self.reset_all_counters
    connection.select_value("SELECT reset_all_offices_counters()")
  end
end
