# frozen_string_literal: true

require "rails_helper"

RSpec.describe Views::Reports::ShowComponent, type: :component do
  let(:collectivity) { build_stubbed(:collectivity) }

  before { sign_in_as(organization: collectivity) }

  def render_with_report(*args, **options)
    report = build_stubbed(:report, *args, **options, collectivity: collectivity)
    render_inline described_class.new(report)
  end

  it "composes report details of a new `evaluation_local_habitation`" do
    render_with_report(:evaluation_local_habitation)

    aggregate_failures do
      expect(page).to have_selector("h2", text: "Objet du signalement")
      expect(page).to have_selector("h2", text: "Identification MAJIC")
      expect(page).to have_selector("h2", text: "Observations")
    end
  end

  it "composes report details of a new `evaluation_local_habitation` with a `consistance` anomalies" do
    render_with_report(:evaluation_local_habitation, anomalies: %w[consistance])

    aggregate_failures do
      expect(page).to have_selector("h2", text: "Objet du signalement")
      expect(page).to have_selector("h2", text: "Identification MAJIC")
      expect(page).to have_selector("h2", text: "Évaluation actuelle")
      expect(page).to have_selector("h2", text: "Proposition de mise à jour de la consistance")
      expect(page).to have_selector("h2", text: "Observations")
    end
  end

  it "composes report details of a new `evaluation_local_habitation` with an `affectation` anomalies" do
    render_with_report(:evaluation_local_habitation, anomalies: %w[affectation])

    aggregate_failures do
      expect(page).to have_selector("h2", text: "Objet du signalement")
      expect(page).to have_selector("h2", text: "Identification MAJIC")
      expect(page).to have_selector("h2", text: "Évaluation actuelle")
      expect(page).to have_selector("h2", text: "Proposition de mise à jour de l'affectation")
      expect(page).to have_selector("h2", text: "Observations")
    end
  end

  it "composes report details of a new `evaluation_local_habitation` with an `correctif` anomalies" do
    render_with_report(:evaluation_local_habitation, anomalies: %w[correctif])

    aggregate_failures do
      expect(page).to have_selector("h2", text: "Objet du signalement")
      expect(page).to have_selector("h2", text: "Identification MAJIC")
      expect(page).to have_selector("h2", text: "Évaluation actuelle")
      expect(page).to have_selector("h2", text: "Proposition de mise à jour du correctif")
    end
  end

  it "composes report details of a new `evaluation_local_habitation` with an `exoneration` anomalies" do
    render_with_report(:evaluation_local_habitation, anomalies: %w[exoneration])

    aggregate_failures do
      expect(page).to have_selector("h2", text: "Objet du signalement")
      expect(page).to have_selector("h2", text: "Identification MAJIC")
      expect(page).to have_selector("h2", text: "Évaluation actuelle")
      expect(page).to have_selector("h2", text: "Proposition de mise à jour des exonérations")
      expect(page).to have_selector("h2", text: "Observations")
    end
  end

  it "composes report details of a new `evaluation_local_habitation` with an `adresse` anomalies" do
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

  it "composes report details of a new `evaluation_local_professionnel` with a `consistance` anomalies" do
    render_with_report(:evaluation_local_professionnel, anomalies: %w[consistance])

    aggregate_failures do
      expect(page).to have_selector("h2", text: "Objet du signalement")
      expect(page).to have_selector("h2", text: "Identification MAJIC")
      expect(page).to have_selector("h2", text: "Évaluation actuelle")
      expect(page).to have_selector("h2", text: "Proposition de mise à jour de la consistance")
      expect(page).to have_selector("h2", text: "Observations")
    end
  end

  it "composes report details of a new `evaluation_local_professionnel` with an `affectation` anomalies" do
    render_with_report(:evaluation_local_professionnel, anomalies: %w[affectation])

    aggregate_failures do
      expect(page).to have_selector("h2", text: "Objet du signalement")
      expect(page).to have_selector("h2", text: "Identification MAJIC")
      expect(page).to have_selector("h2", text: "Évaluation actuelle")
      expect(page).to have_selector("h2", text: "Proposition de mise à jour de l'affectation")
      expect(page).to have_selector("h2", text: "Observations")
    end
  end

  it "composes report details of a new `evaluation_local_professionnel` with an `categorie` anomalies" do
    render_with_report(:evaluation_local_professionnel, anomalies: %w[categorie])

    aggregate_failures do
      expect(page).to have_selector("h2", text: "Objet du signalement")
      expect(page).to have_selector("h2", text: "Identification MAJIC")
      expect(page).to have_selector("h2", text: "Évaluation actuelle")
      expect(page).to have_selector("h2", text: "Proposition de mise à jour de l'utilisation")
    end
  end

  it "composes report details of a new `evaluation_local_professionnel` with an `exoneration` anomalies" do
    render_with_report(:evaluation_local_professionnel, anomalies: %w[exoneration])

    aggregate_failures do
      expect(page).to have_selector("h2", text: "Objet du signalement")
      expect(page).to have_selector("h2", text: "Identification MAJIC")
      expect(page).to have_selector("h2", text: "Évaluation actuelle")
      expect(page).to have_selector("h2", text: "Proposition de mise à jour des exonérations")
      expect(page).to have_selector("h2", text: "Observations")
    end
  end

  it "composes report details of a new `evaluation_local_professionnel` with an `adresse` anomalies" do
    render_with_report(:evaluation_local_professionnel, anomalies: %w[adresse])

    aggregate_failures do
      expect(page).to have_selector("h2", text: "Objet du signalement")
      expect(page).to have_selector("h2", text: "Identification MAJIC")
      expect(page).to have_selector("h2", text: "Proposition de mise à jour de l'adresse")
      expect(page).to have_selector("h2", text: "Observations")
    end
  end
end
