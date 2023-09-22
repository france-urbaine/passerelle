# frozen_string_literal: true

require "rails_helper"

RSpec.describe Views::Reports::ShowReportNameComponent, type: :component do
  it "renders the report form type by default" do
    report = build_stubbed(:report, form_type: "evaluation_local_habitation")

    render_inline described_class.new(report)

    expect(page).to have_text("Évaluation d'un local d'habitation")
  end

  it "renders the report form type with its invariant" do
    report = build_stubbed(:report,
      form_type: "evaluation_local_habitation",
      situation_invariant: "1234567890",
      situation_adresse: "Avenue des Champs")

    render_inline described_class.new(report)

    expect(page).to have_text("Évaluation du local d'habitation 1234567890")
  end

  it "renders the report form type with its address" do
    report = build_stubbed(:report,
      form_type: "evaluation_local_habitation",
      situation_adresse: "Avenue des Champs")

    render_inline described_class.new(report)

    expect(page).to have_text("Évaluation d'un local situé Avenue des Champs")
  end

  it "renders the report form type with its compiled address" do
    report = build_stubbed(:report,
      form_type: "creation_local_habitation",
      situation_numero_voie: 40,
      situation_libelle_voie: "Avenue des Champs")

    render_inline described_class.new(report)

    expect(page).to have_text("Création d'un local situé 40 Avenue des Champs")
  end
end
