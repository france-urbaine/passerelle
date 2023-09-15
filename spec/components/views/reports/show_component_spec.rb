# frozen_string_literal: true

require "rails_helper"

RSpec.describe Views::Reports::ShowComponent, type: :component do
  let(:collectivity) { build_stubbed(:collectivity) }

  before { sign_in_as(organization: collectivity) }

  def render_with_report(*, **)
    report = build_stubbed(:report, *, collectivity:, **)
    render_inline described_class.new(report)
    report
  end

  it "composes report details of a new `evaluation_local_habitation`" do
    render_with_report(:evaluation_local_habitation)

    aggregate_failures do
      expect(page).to have_selector("h2", text: "Objet du signalement")
      expect(page).to have_selector("h2", text: "Identification MAJIC")
      expect(page).to have_selector("h2", text: "Observations")
    end
  end

  it "composes report details of a new `evaluation_local_habitation` with a `consistance` anomaly" do
    render_with_report(:evaluation_local_habitation, anomalies: %w[consistance])

    aggregate_failures do
      expect(page).to have_selector("h2", text: "Objet du signalement")
      expect(page).to have_selector("h2", text: "Identification MAJIC")
      expect(page).to have_selector("h2", text: "Évaluation actuelle")
      expect(page).to have_selector("h2", text: "Proposition de mise à jour de la consistance")
      expect(page).to have_selector("h2", text: "Observations")
    end
  end

  it "composes report details of a new `evaluation_local_habitation` with an `affectation` anomaly" do
    render_with_report(:evaluation_local_habitation, anomalies: %w[affectation])

    aggregate_failures do
      expect(page).to have_selector("h2", text: "Objet du signalement")
      expect(page).to have_selector("h2", text: "Identification MAJIC")
      expect(page).to have_selector("h2", text: "Évaluation actuelle")
      expect(page).to have_selector("h2", text: "Proposition de mise à jour de l'affectation")
      expect(page).to have_selector("h2", text: "Observations")
    end
  end

  it "composes report details of a new `evaluation_local_habitation` with a `correctif` anomaly" do
    render_with_report(:evaluation_local_habitation, anomalies: %w[correctif])

    aggregate_failures do
      expect(page).to have_selector("h2", text: "Objet du signalement")
      expect(page).to have_selector("h2", text: "Identification MAJIC")
      expect(page).to have_selector("h2", text: "Évaluation actuelle")
      expect(page).to have_selector("h2", text: "Proposition de mise à jour du correctif")
    end
  end

  it "composes report details of a new `evaluation_local_habitation` with an `exoneration` anomaly" do
    render_with_report(:evaluation_local_habitation, anomalies: %w[exoneration])

    aggregate_failures do
      expect(page).to have_selector("h2", text: "Objet du signalement")
      expect(page).to have_selector("h2", text: "Identification MAJIC")
      expect(page).to have_selector("h2", text: "Évaluation actuelle")
      expect(page).to have_selector("h2", text: "Proposition de mise à jour des exonérations")
      expect(page).to have_selector("h2", text: "Observations")
    end
  end

  it "composes report details of a new `evaluation_local_habitation` with an `adresse` anomaly" do
    render_with_report(:evaluation_local_habitation, anomalies: %w[adresse])

    aggregate_failures do
      expect(page).to have_selector("h2", text: "Objet du signalement")
      expect(page).to have_selector("h2", text: "Identification MAJIC")
      expect(page).to have_selector("h2", text: "Proposition de mise à jour de l'adresse")
      expect(page).to have_selector("h2", text: "Observations")
    end
  end

  it "composes report details of a new `evaluation_local_professionnel`" do
    render_with_report(:evaluation_local_professionnel)

    aggregate_failures do
      expect(page).to have_selector("h2", text: "Objet du signalement")
      expect(page).to have_selector("h2", text: "Identification MAJIC")
    end
  end

  it "composes report details of a new `evaluation_local_professionnel` with a `consistance` anomaly" do
    render_with_report(:evaluation_local_professionnel, anomalies: %w[consistance])

    aggregate_failures do
      expect(page).to have_selector("h2", text: "Objet du signalement")
      expect(page).to have_selector("h2", text: "Identification MAJIC")
      expect(page).to have_selector("h2", text: "Évaluation actuelle")
      expect(page).to have_selector("h2", text: "Proposition de mise à jour de la consistance")
      expect(page).to have_selector("h2", text: "Observations")
    end
  end

  it "composes report details of a new `evaluation_local_professionnel` with an `affectation` anomaly" do
    render_with_report(:evaluation_local_professionnel, anomalies: %w[affectation])

    aggregate_failures do
      expect(page).to have_selector("h2", text: "Objet du signalement")
      expect(page).to have_selector("h2", text: "Identification MAJIC")
      expect(page).to have_selector("h2", text: "Évaluation actuelle")
      expect(page).to have_selector("h2", text: "Proposition de mise à jour de l'affectation")
      expect(page).to have_selector("h2", text: "Observations")
    end
  end

  it "composes report details of a new `evaluation_local_professionnel` with a `categorie` anomaly" do
    render_with_report(:evaluation_local_professionnel, anomalies: %w[categorie])

    aggregate_failures do
      expect(page).to have_selector("h2", text: "Objet du signalement")
      expect(page).to have_selector("h2", text: "Identification MAJIC")
      expect(page).to have_selector("h2", text: "Évaluation actuelle")
      expect(page).to have_selector("h2", text: "Proposition de mise à jour de l'utilisation")
    end
  end

  it "composes report details of a new `evaluation_local_professionnel` with an `exoneration` anomaly" do
    render_with_report(:evaluation_local_professionnel, anomalies: %w[exoneration])

    aggregate_failures do
      expect(page).to have_selector("h2", text: "Objet du signalement")
      expect(page).to have_selector("h2", text: "Identification MAJIC")
      expect(page).to have_selector("h2", text: "Évaluation actuelle")
      expect(page).to have_selector("h2", text: "Proposition de mise à jour des exonérations")
      expect(page).to have_selector("h2", text: "Observations")
    end
  end

  it "composes report details of a new `evaluation_local_professionnel` with an `adresse` anomaly" do
    render_with_report(:evaluation_local_professionnel, anomalies: %w[adresse])

    aggregate_failures do
      expect(page).to have_selector("h2", text: "Objet du signalement")
      expect(page).to have_selector("h2", text: "Identification MAJIC")
      expect(page).to have_selector("h2", text: "Proposition de mise à jour de l'adresse")
      expect(page).to have_selector("h2", text: "Observations")
    end
  end

  it "composes report details of a new `creation_local_habitation`" do
    render_with_report(:creation_local_habitation)

    aggregate_failures do
      expect(page).to have_selector("h2", text: "Objet du signalement")
      expect(page).to have_selector("h2", text: "Identification de la parcelle")
      expect(page).to have_selector("h2", text: "Observations")
    end
  end

  it "composes report details of a new `creation_local_habitation` with a `omission_batie` anomaly" do
    render_with_report(:creation_local_habitation, anomalies: %w[omission_batie])

    aggregate_failures do
      expect(page).to have_selector("h2", text: "Objet du signalement")
      expect(page).to have_selector("h2", text: "Identification de la parcelle")
      expect(page).to have_selector("h2", text: "Signalement d'une omission bâtie")
      expect(page).to have_selector("h2", text: "Observations")
    end
  end

  it "composes report details of a new `creation_local_habitation` with a `construction_neuve` anomaly" do
    render_with_report(:creation_local_habitation, anomalies: %w[construction_neuve])

    aggregate_failures do
      expect(page).to have_selector("h2", text: "Objet du signalement")
      expect(page).to have_selector("h2", text: "Identification de la parcelle")
      expect(page).to have_selector("h2", text: "Signalement de l'achèvement de travaux")
      expect(page).to have_selector("h2", text: "Observations")
    end
  end

  it "composes report details of a new `creation_local_professionnel`" do
    render_with_report(:creation_local_professionnel)

    aggregate_failures do
      expect(page).to have_selector("h2", text: "Objet du signalement")
      expect(page).to have_selector("h2", text: "Identification de la parcelle")
      expect(page).to have_selector("h2", text: "Observations")
    end
  end

  it "composes report details of a new `creation_local_professionnel` with a `omission_batie` anomaly" do
    render_with_report(:creation_local_professionnel, anomalies: %w[omission_batie])

    aggregate_failures do
      expect(page).to have_selector("h2", text: "Objet du signalement")
      expect(page).to have_selector("h2", text: "Identification de la parcelle")
      expect(page).to have_selector("h2", text: "Signalement d'une omission bâtie")
      expect(page).to have_selector("h2", text: "Observations")
    end
  end

  it "composes report details of a new `creation_local_professionnel` with a `construction_neuve` anomaly" do
    render_with_report(:creation_local_professionnel, anomalies: %w[construction_neuve])

    aggregate_failures do
      expect(page).to have_selector("h2", text: "Objet du signalement")
      expect(page).to have_selector("h2", text: "Identification de la parcelle")
      expect(page).to have_selector("h2", text: "Signalement de l'achèvement de travaux")
      expect(page).to have_selector("h2", text: "Observations")
    end
  end

  it "composes report details of a new `occupation_local_habitation` with a `occupation` anomaly" do
    render_with_report(:occupation_local_habitation, anomalies: %w[occupation])

    aggregate_failures do
      expect(page).to have_selector("h2", text: "Objet du signalement")
      expect(page).to have_selector("h2", text: "Identification MAJIC")
      expect(page).to have_selector("h2", text: "Évaluation actuelle")
      expect(page).to have_selector("h2", text: "Situation actuelle de l'occupation")
      expect(page).to have_selector("h2", text: "Proposition de mise à jour de l'occupation")
      expect(page).to have_selector("h2", text: "Observations")
    end
  end

  it "composes report details of a new `occupation_local_professionnel` with a `occupation` anomaly" do
    render_with_report(:occupation_local_professionnel, anomalies: %w[occupation])

    aggregate_failures do
      expect(page).to have_selector("h2", text: "Objet du signalement")
      expect(page).to have_selector("h2", text: "Identification MAJIC")
      expect(page).to have_selector("h2", text: "Évaluation actuelle")
      expect(page).to have_selector("h2", text: "Situation actuelle de l'occupation")
      expect(page).to have_selector("h2", text: "Proposition de mise à jour de l'occupation")
      expect(page).to have_selector("h2", text: "Observations")
    end
  end
end
