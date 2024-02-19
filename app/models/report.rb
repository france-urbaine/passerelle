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
#  sandbox                                        :boolean          default(FALSE), not null
#  office_id                                      :uuid
#  assignee_id                                    :uuid
#  ddfip_id                                       :uuid
#  state                                          :enum             default("draft"), not null
#  completed_at                                   :datetime
#  transmitted_at                                 :datetime
#  acknowledged_at                                :datetime
#  accepted_at                                    :datetime
#  assigned_at                                    :datetime
#  resolved_at                                    :datetime
#  returned_at                                    :datetime
#
# Indexes
#
#  index_reports_on_assignee_id      (assignee_id)
#  index_reports_on_collectivity_id  (collectivity_id)
#  index_reports_on_ddfip_id         (ddfip_id)
#  index_reports_on_office_id        (office_id)
#  index_reports_on_package_id       (package_id)
#  index_reports_on_publisher_id     (publisher_id)
#  index_reports_on_reference        (reference) UNIQUE
#  index_reports_on_sibling_id       (sibling_id)
#  index_reports_on_state            (state)
#  index_reports_on_transmission_id  (transmission_id)
#  index_reports_on_workshop_id      (workshop_id)
#
# Foreign Keys
#
#  fk_rails_...  (assignee_id => users.id) ON DELETE => nullify
#  fk_rails_...  (collectivity_id => collectivities.id) ON DELETE => cascade
#  fk_rails_...  (ddfip_id => ddfips.id) ON DELETE => nullify
#  fk_rails_...  (office_id => offices.id) ON DELETE => nullify
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
  belongs_to :office,       optional: true
  belongs_to :assignee,     optional: true, class_name: "User", inverse_of: :assigned_reports
  belongs_to :ddfip,        optional: true

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
  scope :in_active_transmission,     -> { packing.where.not(transmission_id: nil) }
  scope :not_in_active_transmission, -> { where(transmission_id: nil) }

  scope :in_transmission,     ->(transmission) { where(transmission_id: transmission.id) }
  scope :not_in_transmission, ->(transmission) { where.not(transmission_id: transmission.id).or(where(transmission_id: nil)) }

  scope :transmitted_or_made_through_web_ui, -> { transmitted.or(where(publisher_id: nil)) }

  scope :transmitted_to_ddfip, ->(ddfip)  { transmitted.where(ddfip: ddfip) }
  scope :assigned_to_office,   ->(office) { assigned.where(office: office) }

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

  # Scopes: searches
  # ----------------------------------------------------------------------------
  scope :search, lambda { |input|
    advanced_search(
      input,
      default: %i[
        reference
        invariant
        package_reference
        form_type
        commune_name
        address
      ],
      scopes: {
        state:             ->(value) { search_by_state(value) },
        reference:         ->(value) { where(reference: value) },
        invariant:         ->(value) { where(situation_invariant: value) },
        package_reference: ->(value) { where(package_id: Package.where(reference: value)) },
        form_type:         ->(value) { search_by_form_type(value) },
        commune_name:      ->(value) { search_by_commune(value) },
        address:           ->(value) { search_by_address(value) }
      }
    )
  }

  scope :search_by_state, lambda { |value|
    values = Array.wrap(value) & States::ReportStates::STATES
    if values.any?
      where(state: values)
    else
      none
    end
  }

  scope :search_by_commune, lambda { |value|
    left_joins(:commune).merge(Commune.search(name: value))
  }

  scope :search_by_form_type, lambda { |value|
    match_enum(:form_type, value, i81n_path: "enum.report_form_type")
  }

  scope :search_by_address, lambda { |value|
    value = sanitize_sql_like(value).squish
    value = "%#{value}%"

    where(<<~SQL.squish, value)
      LOWER(UNACCENT(REPLACE(CONCAT(
        situation_adresse,
        ' ',
        situation_numero_voie,
        ' ',
        situation_indice_repetition,
        ' ',
        situation_libelle_voie
      ), '  ', ' ' ))) LIKE LOWER(UNACCENT(?))
    SQL
  }

  # Scopes: orders
  # ----------------------------------------------------------------------------
  scope :order_by_param, lambda { |input|
    advanced_order(
      input,
      invariant:      ->(direction) { order(situation_invariant: direction) },
      priority:       ->(direction) { order(priority: direction) },
      reference:      ->(direction) { order(reference: direction) },
      state:          ->(direction) { order_by_state(direction) },
      form_type:      ->(direction) { order_by_form_type(direction) },
      anomalies:      ->(direction) { order_by_anomalies(direction) },
      adresse:        ->(direction) { order_by_address(direction) },
      commune:        ->(direction) { order_by_commune(direction) },
      collectivity:   ->(direction) { order_by_collectivity(direction) },
      ddfip:          ->(direction) { order_by_ddfip(direction) },
      office:         ->(direction) { order_by_office(direction) },
      accepted_at:    ->(direction) { order(accepted_at: direction) },
      transmitted_at: ->(direction) { order(transmitted_at: direction) },
      assigned_at:    ->(direction) { order(assigned_at: direction) },
      resolved_at:    ->(direction) { order(resolved_at: direction) },
      returned_at:    ->(direction) { order(returned_at: direction) }
    )
  }

  scope :order_by_score, lambda { |_input|
    # TODO: Not implemented
    self
  }

  scope :order_by_state, ->(direction = :asc) { order(state: direction) }

  SORTED_FORM_TYPES_BY_LABEL = Rails.application.config.i18n.available_locales.index_with { |locale|
    I18n.t("enum.report_form_type", raise: true, locale:).to_a
      .sort_by { |(_, value)| I18n.transliterate(value) }
      .map     { |(key, _)| key.to_s }
  }.freeze

  scope :order_by_form_type, lambda { |direction = :asc|
    values = SORTED_FORM_TYPES_BY_LABEL[I18n.locale]
    values = values.reverse if direction.to_s == "desc"

    in_order_of(:form_type, values)
  }

  SORTED_ANOMALIES_BY_LABEL = Rails.application.config.i18n.available_locales.index_with { |locale|
    I18n.t("enum.anomalies", raise: true, locale:).to_a
      .select  { |(_, value)| value.is_a?(String) }
      .sort_by { |(_, value)| I18n.transliterate(value) }
      .map     { |(key, _)| key.to_s }
  }.freeze

  scope :order_by_anomalies, lambda { |direction = :asc|
    desc   = direction.to_s == "desc"
    values = SORTED_ANOMALIES_BY_LABEL[I18n.locale]
    values = values.reverse if direction.to_s == "desc"

    sql = "CASE"

    values.each.with_index(1) do |value, order|
      sql += %( WHEN "anomalies"[1] = '#{value}' THEN #{order})
    end

    sql += " ELSE #{desc ? 0 : values.size + 1}"
    sql += " END"

    order(Arel.sql(sql) => :asc)
  }

  scope :order_by_address, lambda { |direction = :asc|
    order(Arel.sql(<<~SQL.squish) => direction)
      CONCAT(situation_libelle_voie, situation_numero_voie, situation_indice_repetition, situation_adresse)
    SQL
  }

  scope :order_by_commune, lambda { |direction = :asc|
    left_joins(:commune).merge(Commune.order_by_name(direction))
  }

  scope :order_by_collectivity, lambda { |direction = :asc|
    left_joins(:collectivity).merge(Collectivity.order_by_name(direction))
  }

  scope :order_by_ddfip, lambda { |direction = :asc|
    left_joins(:ddfip).merge(DDFIP.order_by_name(direction))
  }

  scope :order_by_office, lambda { |direction = :asc|
    left_joins(:office).merge(Office.order_by_name(direction))
  }

  # Predicates
  # ----------------------------------------------------------------------------
  def covered_by_ddfip?(ddfip)
    ddfip.code_departement == commune.code_departement
  end

  def covered_by_office?(office)
    office.competences.include?(form_type) && (
      (office.office_communes.loaded? && office.office_communes.any? { |o| o.code_insee == code_insee }) ||
      (!office.office_communes.loaded? && office.office_communes.exists?(code_insee: code_insee))
    )
  end

  def covered_by_offices?(offices)
    offices&.map(&:id)&.include?(office_id)
  end

  def in_active_transmission?
    ready? && transmission_id?
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
