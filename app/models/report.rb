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
#  form_type                                      :enum             not null
#  anomalies                                      :enum             not null, is an Array
#  completed                                      :boolean          default(FALSE), not null
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
#  index_reports_on_collectivity_id  (collectivity_id)
#  index_reports_on_package_id       (package_id)
#  index_reports_on_publisher_id     (publisher_id)
#  index_reports_on_reference        (reference) UNIQUE
#  index_reports_on_sibling_id       (sibling_id)
#  index_reports_on_workshop_id      (workshop_id)
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

  has_many :offices, ->(report) { distinct.where(competences: report.competence) }, through: :potential_office_communes, source: :office

  has_many :exonerations, class_name: "ReportExoneration", dependent: false

  # Attachments
  # ----------------------------------------------------------------------------
  has_many_attached :images
  has_many_attached :documents

  # Attributes
  # ----------------------------------------------------------------------------
  accepts_nested_attributes_for :exonerations, reject_if: :all_blank, allow_destroy: true

  # Validations
  # ----------------------------------------------------------------------------
  PRIORITIES = %w[low medium high].freeze

  FORM_TYPES = %w[
    evaluation_local_habitation
    evaluation_local_professionnel
    creation_local_habitation
    creation_local_professionnel
    occupation_local_habitation
    occupation_local_professionnel
  ].freeze

  ANOMALIES = %w[
    consistance
    affectation
    categorie
    exoneration
    correctif
    omission_batie
    construction_neuve
    occupation
    adresse
  ].freeze

  FORM_TYPE_ANOMALIES = {
    "evaluation_local_habitation"    => %w[consistance affectation exoneration correctif adresse],
    "evaluation_local_professionnel" => %w[consistance affectation categorie exoneration adresse],
    "creation_local_habitation"      => %w[omission_batie construction_neuve],
    "creation_local_professionnel"   => %w[omission_batie construction_neuve],
    "occupation_local_habitation"    => %w[occupation adresse],
    "occupation_local_professionnel" => %w[occupation adresse]
  }.freeze

  validates :reference, presence: true, uniqueness: { unless: :skip_uniqueness_validation_of_reference? }
  validates :form_type, presence: true, inclusion: { in: FORM_TYPES, allow_blank: true }
  validates :anomalies, array: true

  validates :anomalies, inclusion: {
    in: ->(report) { FORM_TYPE_ANOMALIES[report.form_type] },
    if: :form_type?,
    allow_blank: true
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

    validates :situation_affectation,  inclusion: { in: :valid_affectations }
    validates :situation_nature,       inclusion: { in: :valid_natures }
    validates :situation_categorie,    inclusion: { in: :valid_categories }

    validates :proposition_affectation, inclusion: { in: :valid_affectations }
    validates :proposition_nature,      inclusion: { in: :valid_natures }
    validates :proposition_categorie,   inclusion: { in: :valid_categories }

    validates :situation_surface_reelle,   numericality: { greater_than: 0 }
    validates :situation_surface_p1,       numericality: { greater_than_or_equal_to: 0 }
    validates :situation_surface_p2,       numericality: { greater_than_or_equal_to: 0 }
    validates :situation_surface_p3,       numericality: { greater_than_or_equal_to: 0 }
    validates :situation_surface_pk1,      numericality: { greater_than_or_equal_to: 0 }
    validates :situation_surface_pk2,      numericality: { greater_than_or_equal_to: 0 }
    validates :situation_surface_ponderee, numericality: { greater_than: 0 }

    validates :proposition_surface_reelle,   numericality: { greater_than: 0 }
    validates :proposition_surface_p1,       numericality: { greater_than_or_equal_to: 0 }
    validates :proposition_surface_p2,       numericality: { greater_than_or_equal_to: 0 }
    validates :proposition_surface_p3,       numericality: { greater_than_or_equal_to: 0 }
    validates :proposition_surface_pk1,      numericality: { greater_than_or_equal_to: 0 }
    validates :proposition_surface_pk2,      numericality: { greater_than_or_equal_to: 0 }
    validates :proposition_surface_ponderee, numericality: { greater_than: 0 }
  end

  def valid_affectations
    I18n.t("enum.local_affectation").keys.map(&:to_s)
  end

  def valid_natures
    I18n.t("enum.local_nature").keys.map(&:to_s)
  end

  def valid_categories
    (I18n.t("enum.local_habitation_categorie").keys + I18n.t("enum.local_professionnel_categorie").keys).map(&:to_s)
  end

  # Callbacks
  # ----------------------------------------------------------------------------
  before_save :generate_sibling_id

  def generate_sibling_id
    self.sibling_id = ("#{code_insee}#{situation_invariant}" if code_insee? && situation_invariant?)
  end

  # Scopes
  # ----------------------------------------------------------------------------
  scope :sandbox,             -> { joins(:package).merge(Package.unscoped.sandbox) }
  scope :out_of_sandbox,      -> { joins(:package).merge(Package.unscoped.out_of_sandbox) }
  scope :packing,             -> { joins(:package).merge(Package.unscoped.packing) }
  scope :transmitted,         -> { joins(:package).merge(Package.unscoped.transmitted) }
  scope :all_kept,            -> { joins(:package).merge(Package.unscoped.kept).kept }
  scope :published,           -> { transmitted.all_kept.out_of_sandbox }
  scope :approved_packages,   -> { joins(:package).merge(Package.unscoped.approved) }
  scope :rejected_packages,   -> { joins(:package).merge(Package.unscoped.rejected) }
  scope :unrejected_packages, -> { joins(:package).merge(Package.unscoped.unrejected) }

  scope :pending,          -> { published.where(approved_at: nil, rejected_at: nil, debated_at: nil) }
  scope :updated_by_ddfip, -> { approved.or(rejected).or(debated) }
  scope :approved,         -> { published.where.not(approved_at: nil) }
  scope :rejected,         -> { published.where.not(rejected_at: nil) }
  scope :debated,          -> { published.where.not(debated_at: nil) }

  scope :packed_through_publisher_api, -> { where.not(publisher_id: nil) }
  scope :packed_through_web_ui,        -> { where(publisher_id: nil) }

  scope :sent_by_collectivity, ->(collectivity) { where(collectivity: collectivity) }
  scope :sent_by_publisher,    ->(publisher)    { where(publisher: publisher) }

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
        .where(%{"reports"."form_type" = ANY ("offices"."competences")})
    else
      distinct
        .joins(:potential_office_communes)
        .merge(OfficeCommune.where(office: office))
        .where(form_type: office.competences)
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

  scope :order_by_param, lambda { |input|
    advanced_order(
      input,
      reference: ->(direction) { order(reference: direction) }
    )
  }

  scope :order_by_score, lambda { |_input|
    # TODO
    self
  }

  # Predicates
  # ----------------------------------------------------------------------------
  delegate :sandbox?, :out_of_sandbox?, :transmitted?, to: :package, allow_nil: true

  def packing?
    package&.packing? || new_record?
  end

  def all_kept?
    kept? && package&.kept?
  end

  def published?
    transmitted? && all_kept? && out_of_sandbox?
  end

  def approved_package?
    package&.approved?
  end

  def rejected_package?
    package&.rejecetd?
  end

  def unrejected_package?
    package&.unrejected?
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

  def packed_through_publisher_api?
    publisher_id? || (new_record? && publisher)
  end

  def packed_through_web_ui?
    !packed_through_publisher_api?
  end

  def sent_by_collectivity?(collectivity)
    (collectivity_id == collectivity.id) || (new_record? && collectivity == self.collectivity)
  end

  def sent_by_publisher?(publisher)
    (publisher_id == publisher.id) || (new_record? && publisher == self.publisher)
  end

  def covered_by_ddfip?(ddfip)
    ddfip.code_departement == commune.code_departement
  end

  def covered_by_office?(office)
    office.competences.include?(form_type) && office.communes.where(code_insee: code_insee).exist?
  end

  def covered_by_offices?(offices)
    offices.joins(:communes)
      .where(%{? = ANY ("offices"."competences")}, form_type)
      .merge(Commune.where(code_insee: code_insee))
      .exists?
  end

  # Updates methods
  # ----------------------------------------------------------------------------
  # When no selection is made for a collection of checkboxes, most web browsers
  # wont't send any value.
  #
  # `collection_check_boxes` adds a blank value to the array:
  #   ["", "consistance", "adresse"]
  #
  def anomalies=(value)
    value.compact_blank! if value.is_a?(Array)
    super(value)
  end

  def approve!
    return true if approved?

    update_columns(
      approved_at: Time.current,
      rejected_at: nil,
      debated_at: nil
    )
  end

  def reject!
    return true if rejected?

    update_columns(
      rejected_at: Time.current,
      approved_at: nil,
      debated_at: nil
    )
  end

  def debate!
    return true if debated?
    return false if approved? || rejected?

    update_columns(debated_at: Time.current)
  end
end
