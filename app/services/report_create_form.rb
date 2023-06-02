# frozen_string_literal: true

class ReportCreateForm < FormService
  # Use proper names and keys in form builders
  def self.model_name
    Report.model_name
  end

  attr_reader :report
  delegate_missing_to :report

  def initialize(report, current_user = nil, attributes = {})
    @report       = report
    @current_user = current_user

    super(attributes)
    self.models = [report]
  end

  before_validation do
    @report.generate_action

    if @current_user&.organization.is_a?(Collectivity)
      @report.collectivity = @current_user.organization
      @report.package      = find_or_build_package
    end
  end

  SUBJECT_OPTIONS = [
    ["Évaluation de locaux d'habitation", [
      ["Problème d'évaluation d'un local d'habitation",   "evaluation_hab/evaluation",         { disabled: false }],
      ["Problème d'exonération d'un local d'habitation",  "evaluation_hab/exoneration",        { disabled: true }],
      ["Problème d'affectation d'un local d'habitation",  "evaluation_hab/affectation",        { disabled: true }],
      ["Problème d'adresse d'un local d'habitation",      "evaluation_hab/adresse",            { disabled: true }],
      ["Omission bâtie sur un local d'habitation",        "evaluation_hab/omission_batie",     { disabled: true }],
      ["Achèvement de travaux sur un local d'habitation", "evaluation_hab/achevement_travaux", { disabled: true }]
    ]],
    ["Évaluation de locaux économiques", [
      ["Problème d'exonération d'un local économique",  "evaluation_eco/evaluation",         { disabled: true }],
      ["Problème d'évaluation d'un local économique",   "evaluation_eco/exoneration",        { disabled: true }],
      ["Problème d'affectation d'un local économique",  "evaluation_eco/affectation",        { disabled: true }],
      ["Problème d'adresse d'un local économique",      "evaluation_eco/adresse",            { disabled: true }],
      ["Omission bâtie sur un local économique",        "evaluation_eco/omission_batie",     { disabled: true }],
      ["Achèvement de travaux sur un local économique", "evaluation_eco/achevement_travaux", { disabled: true }]
    ]]
  ].freeze

  def subject_options
    SUBJECT_OPTIONS.map do |(name, group)|
      group = group.map do |(name, key, options)|
        name = "(Bientôt disponible) #{name}" if options[:disabled]
        [name, key, options]
      end

      [name, group]
    end
  end

  def find_or_build_package
    return unless @current_user&.organization.is_a?(Collectivity)

    policy   = PackagePolicy.new(user: @current_user)
    packages = @current_user.organization.packages.packing.where(action: action)
    packages = policy.apply_scope(packages, type: :active_record_relation)
    packages.order(created_at: :desc).first_or_initialize do |package|
      package.name = I18n.translate(action, scope: "enum.action")
    end
  end
end