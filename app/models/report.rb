# frozen_string_literal: true

# == Schema Information
#
# Table name: reports
#
#  id                                             :uuid             not null, primary key
#  collectivity_id                                :uuid             not null
#  publisher_id                                   :uuid
#  package_id                                     :uuid
#  workshop_id                                    :uuid
#  sibling_id                                     :string
#  created_at                                     :datetime         not null
#  updated_at                                     :datetime         not null
#  approved_at                                    :datetime
#  rejected_at                                    :datetime
#  debated_at                                     :datetime
#  discarded_at                                   :datetime
#  reference                                      :string
#  form_type                                      :enum             not null
#  anomalies                                      :enum             not null, is an Array
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
#  situation_nature_occupation                    :string
#  situation_majoration_rs                        :boolean
#  situation_annee_cfe                            :string
#  situation_vacance_fiscale                      :boolean
#  situation_nombre_annees_vacance                :string
#  situation_siren_dernier_occupant               :string
#  situation_nom_dernier_occupant                 :string
#  situation_vlf_cfe                              :string
#  situation_taxation_base_minimum                :boolean
#  situation_occupation_annee                     :string
#  proposition_nature_occupation                  :string
#  proposition_date_occupation                    :date
#  proposition_erreur_tlv                         :boolean
#  proposition_erreur_thlv                        :boolean
#  proposition_meuble_tourisme                    :boolean
#  proposition_majoration_rs                      :boolean
#  proposition_nom_occupant                       :string
#  proposition_prenom_occupant                    :string
#  proposition_adresse_occupant                   :string
#  proposition_numero_siren                       :string
#  proposition_nom_societe                        :string
#  proposition_nom_enseigne                       :string
#  proposition_etablissement_principal            :boolean
#  proposition_chantier_longue_duree              :boolean
#  proposition_code_naf                           :string
#  proposition_date_debut_activite                :date
#  transmission_id                                :uuid
#  completed_at                                   :datetime
#  sandbox                                        :boolean          default(FALSE), not null
#
# Indexes
#
#  index_reports_on_collectivity_id  (collectivity_id)
#  index_reports_on_package_id       (package_id)
#  index_reports_on_publisher_id     (publisher_id)
#  index_reports_on_reference        (reference) UNIQUE
#  index_reports_on_sibling_id       (sibling_id)
#  index_reports_on_transmission_id  (transmission_id)
#  index_reports_on_workshop_id      (workshop_id)
#
# Foreign Keys
#
#  fk_rails_...  (collectivity_id => collectivities.id) ON DELETE => cascade
#  fk_rails_...  (package_id => packages.id) ON DELETE => cascade
#  fk_rails_...  (publisher_id => publishers.id) ON DELETE => cascade
#  fk_rails_...  (transmission_id => transmissions.id)
#  fk_rails_...  (workshop_id => workshops.id) ON DELETE => nullify
#
class Report < ApplicationRecord
  include States::ReportStates
  include States::Sandbox
  include States::MadeBy

  audited

  # Associations
  # ----------------------------------------------------------------------------
  belongs_to :collectivity
  belongs_to :publisher,    optional: true
  belongs_to :package,      optional: true
  belongs_to :transmission, optional: true
  belongs_to :workshop,     optional: true
  belongs_to :commune,      optional: true, primary_key: :code_insee, foreign_key: :code_insee, inverse_of: :reports

  has_many :siblings, ->(report) { where.not(id: report.id) }, class_name: "Report", primary_key: :sibling_id, foreign_key: :sibling_id, inverse_of: false, dependent: false

  has_many :potential_office_communes, -> { distinct }, class_name: "OfficeCommune", primary_key: :code_insee, foreign_key: :code_insee, inverse_of: false, dependent: false
  has_many :potential_offices,         -> { distinct }, through: :potential_office_communes, source: :office

  has_many :offices, ->(report) { distinct.where(competences: report.competence) }, through: :potential_office_communes, source: :office

  has_many :exonerations, class_name: "ReportExoneration", dependent: false

  # Attachments
  # ----------------------------------------------------------------------------
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
    "occupation_local_habitation"    => %w[occupation],
    "occupation_local_professionnel" => %w[occupation]
  }.freeze

  validates :reference, uniqueness: { unless: :skip_uniqueness_validation_of_reference?, allow_blank: true }
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

    validates :situation_occupation_annee,       numericality: { in: 2018..Time.current.year }
    validates :situation_nature_occupation,      inclusion: { in: :valid_occupations }
    validates :situation_majoration_rs,          inclusion: [true, false]
    validates :situation_annee_cfe,              numericality: { in: 2018..Time.current.year }
    validates :situation_vacance_fiscale,        inclusion: [true, false]
    validates :situation_nombre_annees_vacance,  numericality: { greater_than_or_equal_to: 0 }
    validates :situation_siren_dernier_occupant, format: { with: SIREN_REGEXP }
    validates :situation_vlf_cfe,                numericality: { greater_than_or_equal_to: 0 }
    validates :situation_taxation_base_minimum,  inclusion: [true, false]

    validates :proposition_nature_occupation,          inclusion: { in: :valid_occupations }
    validates :proposition_erreur_tlv,                 inclusion: [true, false]
    validates :proposition_erreur_thlv,                inclusion: [true, false]
    validates :proposition_meuble_tourisme,            inclusion: [true, false]
    validates :proposition_majoration_rs,              inclusion: [true, false]
    validates :proposition_numero_siren,               format: { with: SIREN_REGEXP }
    validates :proposition_etablissement_principal,    inclusion: [true, false]
    validates :proposition_chantier_longue_duree,      inclusion: [true, false]
    validates :proposition_code_naf,                   format: { with: NAF_REGEXP }
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

  def valid_occupations
    I18n.t("enum.local_habitation_occupation").keys.map(&:to_s)
  end

  # Callbacks
  # ----------------------------------------------------------------------------
  before_save :generate_sibling_id

  def generate_sibling_id
    self.sibling_id = ("#{code_insee}#{situation_invariant}" if code_insee? && situation_invariant?)
  end

  # Scopes
  # ----------------------------------------------------------------------------
  scope :all_kept, lambda {
    kept.left_outer_joins(:package).where(<<~SQL.squish)
         "packages"."id" IS NULL
      OR "packages"."discarded_at" IS NULL
    SQL
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
        .where(%{"reports"."form_type" = ANY ("offices"."competences")})
    else
      distinct
        .joins(:potential_office_communes)
        .merge(OfficeCommune.where(office: office))
        .where(form_type: office.competences)
    end
  }

  scope :transmitted_or_made_through_web_ui, lambda {
    left_outer_joins(:package).where(<<~SQL.squish)
      "packages"."transmitted_at" IS NOT NULL
      OR
      "reports"."publisher_id" IS NULL
    SQL
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
      form_type: lambda { |direction|
        form_type_whens = FORM_TYPES.map do |form_type|
          form_type_label = I18n.t(
            form_type,
            scope: "enum.report_form_type"
          )
          form_type_label.delete!("'")

          "WHEN '#{form_type}' THEN UNACCENT('#{form_type_label}')"
        end

        form_type_case = <<-SQL.squish
          CASE reports.form_type
            #{sanitize_sql(form_type_whens.join(' '))}
          END
        SQL

        order(
          Arel.sql(form_type_case) => direction
        )
      },
      adresse:   lambda { |direction|
        order(
          Arel.sql(
            "CONCAT(situation_adresse, situation_numero_voie, situation_indice_repetition, situation_libelle_voie)"
          ) => direction
        )
      },
      invariant: ->(direction) { order(situation_invariant: direction) },
      commune:   lambda { |direction|
        left_joins(:commune).merge(
          Commune.unaccent_order(:name, direction, nulls: true)
        )
      },
      priority:  ->(direction) { order(priority: direction) },
      package:   lambda { |direction|
        left_joins(:package).merge(
          Package.order(reference: direction)
        )
      },
      reference: ->(direction) { order(reference: direction) }
    )
  }

  scope :order_by_score, lambda { |_input|
    # TODO: Not implemented
    self
  }

  scope :order_by_last_examination_date, lambda {
    order(Arel.sql(%{COALESCE("reports"."rejected_at", "reports"."approved_at", "reports"."debated_at") DESC}))
  }

  scope :order_by_last_transmission_date, lambda {
    joins(:package).merge(Package.order(transmitted_at: :desc))
  }

  # Predicates
  # ----------------------------------------------------------------------------
  def all_kept?
    kept? && (package.nil? || package.kept?)
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
end
