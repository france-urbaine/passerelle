# frozen_string_literal: true

# == Schema Information
#
# Table name: reports
#
#  id                                             :uuid             not null, primary key
#  collectivity_id                                :uuid             not null
#  publisher_id                                   :uuid
#  package_id                                     :uuid             not null
#  workshop_id                                    :uuid
#  sibling_id                                     :string
#  created_at                                     :datetime         not null
#  updated_at                                     :datetime         not null
#  approved_at                                    :datetime
#  rejected_at                                    :datetime
#  debated_at                                     :datetime
#  discarded_at                                   :datetime
#  reference                                      :string           not null
#  action                                         :enum             not null
#  subject                                        :string           not null
#  completed                                      :boolean          default(FALSE), not null
#  sandbox                                        :boolean          default(FALSE), not null
#  priority                                       :enum             default("low"), not null
#  code_insee                                     :string
#  date_constat                                   :date
#  enjeu                                          :text
#  observations                                   :text
#  reponse                                        :text
#  situation_annee_majic                          :integer
#  situation_invariant                            :string
#  situation_proprietaire                         :string
#  situation_numero_ordre_proprietaire            :string
#  situation_parcelle                             :string
#  situation_numero_voie                          :string
#  situation_indice_repetition                    :string
#  situation_libelle_voie                         :string
#  situation_code_rivoli                          :string
#  situation_adresse                              :string
#  situation_numero_batiment                      :string
#  situation_numero_escalier                      :string
#  situation_numero_niveau                        :string
#  situation_numero_porte                         :string
#  situation_numero_ordre_porte                   :string
#  situation_nature                               :string
#  situation_affectation                          :string
#  situation_categorie                            :string
#  situation_surface_reelle                       :float
#  situation_surface_p1                           :float
#  situation_surface_p2                           :float
#  situation_surface_p3                           :float
#  situation_surface_pk1                          :float
#  situation_surface_pk2                          :float
#  situation_surface_ponderee                     :float
#  situation_date_mutation                        :string
#  situation_coefficient_localisation             :string
#  situation_coefficient_entretien                :string
#  situation_coefficient_situation_generale       :string
#  situation_coefficient_situation_particuliere   :string
#  situation_exoneration                          :string
#  proposition_parcelle                           :string
#  proposition_numero_voie                        :string
#  proposition_indice_repetition                  :string
#  proposition_libelle_voie                       :string
#  proposition_code_rivoli                        :string
#  proposition_adresse                            :string
#  proposition_numero_batiment                    :string
#  proposition_numero_escalier                    :string
#  proposition_numero_niveau                      :string
#  proposition_numero_porte                       :string
#  proposition_numero_ordre_porte                 :string
#  proposition_nature                             :string
#  proposition_nature_dependance                  :string
#  proposition_affectation                        :string
#  proposition_categorie                          :string
#  proposition_surface_reelle                     :float
#  proposition_surface_p1                         :float
#  proposition_surface_p2                         :float
#  proposition_surface_p3                         :float
#  proposition_surface_pk1                        :float
#  proposition_surface_pk2                        :float
#  proposition_surface_ponderee                   :float
#  proposition_coefficient_localisation           :string
#  proposition_coefficient_entretien              :string
#  proposition_coefficient_situation_generale     :string
#  proposition_coefficient_situation_particuliere :string
#  proposition_exoneration                        :string
#  proposition_date_achevement                    :string
#  proposition_numero_permis                      :string
#  proposition_nature_travaux                     :string
#
# Indexes
#
#  index_reports_on_collectivity_id     (collectivity_id)
#  index_reports_on_package_id          (package_id)
#  index_reports_on_publisher_id        (publisher_id)
#  index_reports_on_reference           (reference) UNIQUE
#  index_reports_on_sibling_id          (sibling_id)
#  index_reports_on_subject_uniqueness  (sibling_id,subject) UNIQUE WHERE (discarded_at IS NULL)
#  index_reports_on_workshop_id         (workshop_id)
#
# Foreign Keys
#
#  fk_rails_...  (collectivity_id => collectivities.id) ON DELETE => cascade
#  fk_rails_...  (package_id => packages.id) ON DELETE => cascade
#  fk_rails_...  (publisher_id => publishers.id) ON DELETE => cascade
#  fk_rails_...  (workshop_id => workshops.id) ON DELETE => nullify
#
class Report < ApplicationRecord
  # Associations
  # ----------------------------------------------------------------------------
  belongs_to :collectivity
  belongs_to :publisher, optional: true
  belongs_to :package
  belongs_to :workshop, optional: true
  belongs_to :commune,  optional: true, primary_key: :code_insee, foreign_key: :code_insee, inverse_of: :reports

  has_many :siblings, ->(report) { where.not(id: report.id) }, class_name: "Report", primary_key: :sibling_id, foreign_key: :sibling_id, inverse_of: false, dependent: false

  has_many :potential_office_communes, -> { distinct }, class_name: "OfficeCommune", primary_key: :code_insee, foreign_key: :code_insee, inverse_of: false, dependent: false
  has_many :potential_offices,         -> { distinct }, through: :potential_office_communes, source: :office

  has_many :offices, ->(report) { distinct.where(action: report.action) }, through: :potential_office_communes, source: :office

  # Attachments
  # ----------------------------------------------------------------------------
  has_many_attached :images
  has_many_attached :documents

  # Validations
  # ----------------------------------------------------------------------------
  ACTIONS    = %w[evaluation_hab evaluation_eco].freeze
  PRIORITIES = %w[low medium high].freeze

  SUBJECTS = %w[
    evaluation_hab/evaluation
    evaluation_hab/exoneration
    evaluation_hab/affectation
    evaluation_hab/adresse
    evaluation_hab/omission_batie
    evaluation_hab/achevement_travaux
    evaluation_eco/evaluation
    evaluation_eco/exoneration
    evaluation_eco/affectation
    evaluation_eco/adresse
    evaluation_eco/omission_batie
    evaluation_eco/achevement_travaux
  ].freeze

  validates :action,    presence: true, inclusion: { in: ACTIONS, allow_blank: true }
  validates :subject,   presence: true, inclusion: { in: SUBJECTS, allow_blank: true }
  validates :reference, presence: true, uniqueness: { unless: :skip_uniqueness_validation_of_reference? }

  validates :subject,   uniqueness: {
    scope:      :sibling_id,
    unless:     -> { skip_uniqueness_validation_of_subject? || situation_invariant.blank? },
    conditions: -> { kept}
  }

  validates :priority, inclusion: { in: PRIORITIES }

  with_options allow_blank: true do
    validates :situation_annee_majic, numericality: {
      greater_than_or_equal_to: 2018,
      less_than_or_equal_to:    ->(_) { Time.current.year }
    }

    validates :code_insee,                          format: { with: CODE_INSEE_REGEXP }
    validates :situation_invariant,                 format: { with: INVARIANT_REGEXP }
    validates :situation_numero_ordre_proprietaire, format: { with: NUMERO_ORDRE_PROPRIETAIRE_REGEXP }
    validates :situation_parcelle,                  format: { with: PARCELLE_REGEXP }
    validates :situation_numero_voie,               numericality: { in: 0..9999 }
    validates :situation_code_rivoli,               format: { with: CODE_RIVOLI_REGEXP }
    validates :situation_numero_batiment,           format: { with: NUMERO_BATIMENT_REGEXP }
    validates :situation_numero_escalier,           format: { with: NUMERO_ESCALIER_REGEXP }
    validates :situation_numero_niveau,             format: { with: NUMERO_NIVEAU_REGEXP }
    validates :situation_numero_porte,              format: { with: NUMERO_PORTE_REGEXP }
    validates :situation_numero_ordre_porte,        format: { with: NUMERO_ORDRE_PORTE_REGEXP }
    validates :situation_date_mutation,             format: { with: DATE_REGEXP }

    validates :proposition_parcelle,           format: { with: PARCELLE_REGEXP }
    validates :proposition_numero_voie,        numericality: { in: 0..9999 }
    validates :proposition_code_rivoli,        format: { with: CODE_RIVOLI_REGEXP }
    validates :proposition_numero_batiment,    format: { with: NUMERO_BATIMENT_REGEXP }
    validates :proposition_numero_escalier,    format: { with: NUMERO_ESCALIER_REGEXP }
    validates :proposition_numero_niveau,      format: { with: NUMERO_NIVEAU_REGEXP }
    validates :proposition_numero_porte,       format: { with: NUMERO_PORTE_REGEXP }
    validates :proposition_numero_ordre_porte, format: { with: NUMERO_ORDRE_PORTE_REGEXP }
    validates :proposition_date_achevement,    format: { with: DATE_REGEXP }

    # validates :situation_nature,       inclusion: ->(person) { person.valid_natures }
    # validates :situation_affectation,  inclusion: ->(person) { person.valid_affectations }
    # validates :situation_categorie,    inclusion: ->(person) { person.valid_categories }

    # validates :proposition_nature,      inclusion: ->(person) { person.valid_natures }
    # validates :proposition_affectation, inclusion: ->(person) { person.valid_affectations }
    # validates :proposition_categorie,   inclusion: ->(person) { person.valid_categories }

    validates :situation_surface_reelle,   numericality: { greater_than: 0 }
    validates :situation_surface_p1,       numericality: { greater_than: 0 }
    validates :situation_surface_p2,       numericality: { greater_than: 0 }
    validates :situation_surface_p3,       numericality: { greater_than: 0 }
    validates :situation_surface_pk1,      numericality: { greater_than: 0 }
    validates :situation_surface_pk2,      numericality: { greater_than: 0 }
    validates :situation_surface_ponderee, numericality: { greater_than: 0 }

    validates :proposition_surface_reelle,   numericality: { greater_than: 0 }
    validates :proposition_surface_p1,       numericality: { greater_than: 0 }
    validates :proposition_surface_p2,       numericality: { greater_than: 0 }
    validates :proposition_surface_p3,       numericality: { greater_than: 0 }
    validates :proposition_surface_pk1,      numericality: { greater_than: 0 }
    validates :proposition_surface_pk2,      numericality: { greater_than: 0 }
    validates :proposition_surface_ponderee, numericality: { greater_than: 0 }
  end

  def valid_natures
    I18n.translate("enum.natures").keys
  end

  def valid_affectations
    I18n.translate("enum.affectation").keys
  end

  def valid_categories
    case action
    when "evaluation_hab", "occupation_hab" then I18n.translate("enum.categorie_habitation").keys
    when "evaluation_eco", "occupation_eco" then I18n.translate("enum.categorie_economique").keys
    end
  end

  # Callbacks
  # ----------------------------------------------------------------------------
  before_save :generate_sibling_ig

  def generate_sibling_ig
    self.sibling_id =
      if code_insee? && situation_invariant?
        "#{code_insee}#{situation_invariant}"
      end
  end

  # Scopes
  # ----------------------------------------------------------------------------
  # In some scopes we use `model_name.name` to identify the model of either
  # an instance or a relation:
  # Example:
  #    sent_by(Publisher.last)
  #    sent_by(Publisher.all)

  scope :sandbox,        -> { where(sandbox: true) }
  scope :out_of_sandbox, -> { where(sandbox: false) }
  scope :transmitted,    -> { joins(:package).merge(Package.unscoped.transmitted) }
  scope :all_kept,       -> { joins(:package).merge(Package.unscoped.kept).kept }
  scope :published,      -> { transmitted.all_kept.out_of_sandbox }

  scope :pending,  -> { published.where(approved_at: nil, rejected_at: nil, debated_at: nil) }
  scope :approved, -> { published.where.not(approved_at: nil) }
  scope :rejected, -> { published.where.not(rejected_at: nil) }
  scope :debated,  -> { published.where.not(debated_at: nil) }

  scope :sent_by_collectivity, ->(collectivity) { where(collectivity: collectivity) }
  scope :sent_by_publisher,    ->(publisher)    { where(publisher: publisher) }
  scope :sent_by, lambda { |entity|
    case entity.model_name.name
    when "Publisher"    then sent_by_publisher(entity)
    when "Collectivity" then sent_by_collectivity(entity)
    else raise TypeError, "unexpected argument: #{entity}"
    end
  }

  scope :located_in, lambda { |commune|
    if commune.is_a?(ActiveRecord::Relation)
      where(code_insee: commune.select(:code_insee))
    else
      where(code_insee: commune.code_insee)
    end
  }

  scope :covered_by_ddfip, lambda { |ddfip|
    if ddfip.is_a?(ActiveRecord::Relation)
      joins(:commune).merge(Commune.where(code_departement: ddfip.select(:code_departement)))
    else
      joins(:commune).merge(Commune.where(code_departement: ddfip.code_departement))
    end
  }

  scope :covered_by_office, lambda { |office|
    if office.is_a?(ActiveRecord::Relation)
      distinct
        .joins(:potential_offices)
        .merge(office)
        .where(arel_table[:action].eq(Office.arel_table[:action]))
    else
      distinct
        .joins(:potential_office_communes)
        .merge(OfficeCommune.where(office: office))
        .where(action: office.action)
    end
  }

  scope :covered_by, lambda { |entity|
    case entity.model_name.name
    when "DDFIP"  then covered_by_ddfip(entity)
    when "Office" then covered_by_office(entity)
    else raise TypeError, "unexpected argument: #{entity}"
    end
  }

  scope :available_to_collectivity, lambda { |collectivity|
    all_kept.out_of_sandbox.sent_by_collectivity(collectivity).merge(
      Package.unscoped.transmitted.or(
        Package.unscoped.packed_through_collectivity_ui
      )
    )
  }

  scope :available_to_publisher,    ->(publisher)    { all_kept.sent_by_publisher(publisher) }
  scope :available_to_ddfip,  ->(ddfip)  { published.covered_by_ddfip(ddfip).merge(Package.unscoped.kept.unrejected) }
  scope :available_to_office, ->(office) { published.covered_by_office(office).merge(Package.unscoped.kept.approved) }

  scope :available_to, lambda { |entity|
    case entity.model_name.name
    when "Publisher"    then available_to_publisher(entity)
    when "Collectivity" then available_to_collectivity(entity)
    when "DDFIP"        then available_to_ddfip(entity)
    when "Office"       then available_to_office(entity)
    else raise TypeError, "unexpected argument: #{entity}"
    end
  }

  scope :search, lambda { |input|
    advanced_search(
      input,
      reference:         ->(value) { where(reference: value) },
      invariant:         ->(value) { where(situation_invariant: value) },
      package_reference: ->(value) { where(package_id: Package.where(reference: value)) },
      package_name:      ->(value) { where(package_id: Package.match(:name, value)) }
    )
  }

  scope :order_by_score, lambda { |input|
    self
  }

  # Predicates
  # ----------------------------------------------------------------------------
  def transmitted?
    package&.transmitted?
  end

  def published?
    transmitted? && kept? && !sandbox?
  end

  def pending?
    published? && !approved_at? && !rejected_at? && !debated_at?
  end

  def approved?
    published? && approved_at?
  end

  def rejected?
    published? && rejected_at?
  end

  def debated?
    published? && debated_at?
  end
end
