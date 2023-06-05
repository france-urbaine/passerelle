# frozen_string_literal: true

# == Schema Information
#
# Table name: communes
#
#  id                   :uuid             not null, primary key
#  name                 :string           not null
#  code_insee           :string           not null
#  code_departement     :string           not null
#  siren_epci           :string
#  qualified_name       :string
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  collectivities_count :integer          default(0), not null
#  offices_count        :integer          default(0), not null
#
# Indexes
#
#  index_communes_on_code_departement  (code_departement)
#  index_communes_on_code_insee        (code_insee) UNIQUE
#  index_communes_on_siren_epci        (siren_epci)
#
# Foreign Keys
#
#  fk_rails_...  (code_departement => departements.code_departement)
#  fk_rails_...  (siren_epci => epcis.siren) ON UPDATE => cascade
#
class Commune < ApplicationRecord
  self.implicit_order_column = :code_insee

  # Associations
  # ----------------------------------------------------------------------------
  belongs_to :departement, primary_key: :code_departement, foreign_key: :code_departement, inverse_of: :communes
  belongs_to :epci, primary_key: :siren, foreign_key: :siren_epci, inverse_of: :communes, optional: true

  has_one :region, through: :departement

  has_one :registered_collectivity, class_name: "Collectivity", as: :territory, dependent: false

  has_many :ddfips, primary_key: :code_departement, foreign_key: :code_departement, inverse_of: false, dependent: false

  has_many :office_communes, primary_key: :code_insee, foreign_key: :code_insee, inverse_of: :commune, dependent: false
  has_many :offices, through: :office_communes

  has_many :reports, primary_key: :code_insee, foreign_key: :code_insee, inverse_of: :commune, dependent: false

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
  before_validation :normalize_siren_epci
  before_save       :generate_qualified_name, if: :qualified_name_need_to_be_regenerated?

  def normalize_siren_epci
    self.siren_epci = nil if siren_epci.blank?
  end

  def qualified_name_need_to_be_regenerated?
    qualified_name.blank? || (name_changed? && !qualified_name_changed?)
  end

  def generate_qualified_name
    self.qualified_name = self.class.generate_qualified_name(name)
  end

  def self.generate_qualified_name(name)
    "Commune de #{name}"
      .gsub(/\bde Les\b/, "des")
      .gsub(/\bde Le\b/, "du")
      .gsub(/\bde La\b/, "de la")
      .gsub(/\bde (?=[AEÉÈIÎOÔUY])/, "d'")
  end

  # Scopes
  # ----------------------------------------------------------------------------
  scope :covered_by_ddfip, lambda { |ddfip|
    if ddfip.is_a?(ActiveRecord::Relation)
      where(code_departement: ddfip.select(:code_departement))
    else
      where(code_departement: ddfip.code_departement)
    end
  }

  scope :covered_by_office, lambda { |office|
    where(code_insee: OfficeCommune.where(office: office).select(:code_insee))
  }

  scope :covered_by, lambda { |entity|
    # Use `model_name.name`` to match an instance or a relation
    #    covered_by(DDIP.last)
    #    covered_by(Office.all)
    #
    case entity.model_name.name
    when "DDFIP"  then covered_by_ddfip(entity)
    when "Office" then covered_by_office(entity)
    else raise TypeError, "unexpected argument: #{entity}"
    end
  }

  scope :search, lambda { |input|
    advanced_search(
      input,
      name:             ->(value) { match(:name, value) },
      code_insee:       ->(value) { where(code_insee: value) },
      siren_epci:       ->(value) { where(siren_epci: value) },
      code_departement: ->(value) { where(code_departement: value) },
      epci_name:        ->(value) { left_joins(:epci).merge(EPCI.match(:name, value)) },
      departement_name: ->(value) { left_joins(:departement).merge(Departement.match(:name, value)) },
      region_name:      ->(value) { left_joins(:region).merge(Region.match(:name, value)) }
    )
  }

  scope :autocomplete, lambda { |input|
    advanced_search(
      input,
      name:             ->(value) { match(:qualified_name, value) },
      code_insee:       ->(value) { where(code_insee: value) }
    )
  }

  scope :order_by_param, lambda { |input|
    advanced_order(
      input,
      commune:      ->(direction) { unaccent_order(:name, direction) },
      departement:  ->(direction) { order(code_departement: direction) },
      epci:         ->(direction) { left_joins(:epci).merge(EPCI.unaccent_order(:name, direction)) }
    )
  }

  scope :order_by_score, lambda { |input|
    scored_order(:name, input)
  }

  # Other associations
  # ----------------------------------------------------------------------------
  def on_territory_collectivities
    territories = [self]
    territories << EPCI.where(siren: siren_epci) if siren_epci
    territories << Departement.where(code_departement: code_departement)

    Collectivity.kept.where(territory: territories)
  end

  # Database updates
  # ----------------------------------------------------------------------------
  def self.reset_all_counters
    connection.select_value("SELECT reset_all_communes_counters()")
  end
end
