# frozen_string_literal: true

require "rails_helper"

RSpec.describe Views::Reports::EditComponent, type: :component do
  let(:collectivity) { build_stubbed(:collectivity) }

  before { sign_in_as(organization: collectivity) }

  def render_with_report(*, **)
    report = build_stubbed(:report, *, collectivity:, **)
    render_inline described_class.new(report, fields)
    report
  end

  describe "`information` fields" do
    let(:fields) { "information" }

    it "renders a form to edit a new `evaluation_local_habitation`" do
      report = render_with_report(:evaluation_local_habitation)

      expect(page).to have_selector(".modal form") do |form|
        aggregate_failures do
          expect(form).to have_html_attribute("action").with_value("/signalements/#{report.id}")
          expect(form).to have_field("Date du constat")
          expect(form).to have_field("Priorité")
          expect(form).to have_unchecked_field("Changement de consistance")
          expect(form).to have_unchecked_field("Changement d'affectation")
          expect(form).to have_unchecked_field("Exonération à tort")
          expect(form).to have_unchecked_field("Anomalie correctif d'ensemble")
          expect(form).to have_unchecked_field("Changement d'adresse")
        end
      end
    end

    it "renders a form to edit a new `evaluation_local_professionnel`" do
      report = render_with_report(:evaluation_local_professionnel)

      expect(page).to have_selector(".modal form") do |form|
        aggregate_failures do
          expect(form).to have_html_attribute("action").with_value("/signalements/#{report.id}")
          expect(form).to have_field("Date du constat")
          expect(form).to have_field("Priorité")
          expect(form).to have_unchecked_field("Changement de consistance")
          expect(form).to have_unchecked_field("Changement d'affectation (nature du local)")
          expect(form).to have_unchecked_field("Changement d'utilisation (catégorie du local)")
          expect(form).to have_unchecked_field("Exonération à tort")
          expect(form).to have_unchecked_field("Changement d'adresse")
        end
      end
    end

    it "renders a form to edit a new `creation_local_habitation`" do
      report = render_with_report(:creation_local_habitation)

      expect(page).to have_selector(".modal form") do |form|
        aggregate_failures do
          expect(form).to have_html_attribute("action").with_value("/signalements/#{report.id}")
          expect(form).to have_field("Date du constat")
          expect(form).to have_field("Priorité")
          expect(form).to have_unchecked_field("Construction neuve")
          expect(form).to have_unchecked_field("Omission bâtie")
        end
      end
    end

    it "renders a form to edit a new `creation_local_professionnel`" do
      report = render_with_report(:creation_local_professionnel)

      expect(page).to have_selector(".modal form") do |form|
        aggregate_failures do
          expect(form).to have_html_attribute("action").with_value("/signalements/#{report.id}")
          expect(form).to have_field("Date du constat")
          expect(form).to have_field("Priorité")
          expect(form).to have_unchecked_field("Construction neuve")
          expect(form).to have_unchecked_field("Omission bâtie")
        end
      end
    end
  end

  describe "`situation_majic` fields" do
    let(:fields) { "situation_majic" }

    it "renders a form to edit a new `evaluation_local_habitation`" do
      report = render_with_report(:evaluation_local_habitation)

      expect(page).to have_selector(".modal form") do |form|
        aggregate_failures do
          expect(form).to have_html_attribute("action").with_value("/signalements/#{report.id}")
          expect(form).to have_field("Année du fichier MAJIC")
          expect(form).to have_field("Commune")
        end
      end
    end

    it "renders a form to edit a new `evaluation_local_professionnel`" do
      report = render_with_report(:evaluation_local_professionnel)

      expect(page).to have_selector(".modal form") do |form|
        aggregate_failures do
          expect(form).to have_html_attribute("action").with_value("/signalements/#{report.id}")
          expect(form).to have_field("Année du fichier MAJIC")
          expect(form).to have_field("Commune")
        end
      end
    end
  end

  describe "`situation_parcelle` fields" do
    let(:fields) { "situation_parcelle" }

    it "renders a form to edit a new `creation_local_habitation`" do
      report = render_with_report(:creation_local_habitation)

      expect(page).to have_selector(".modal form") do |form|
        aggregate_failures do
          expect(form).to have_html_attribute("action").with_value("/signalements/#{report.id}")
          expect(form).to have_field("Commune")
          expect(form).to have_field("Parcelle")
        end
      end
    end

    it "renders a form to edit a new `creation_local_professionnel`" do
      report = render_with_report(:creation_local_professionnel)

      expect(page).to have_selector(".modal form") do |form|
        aggregate_failures do
          expect(form).to have_html_attribute("action").with_value("/signalements/#{report.id}")
          expect(form).to have_field("Commune")
          expect(form).to have_field("Parcelle")
        end
      end
    end
  end

  describe "`situation_evaluation` fields" do
    let(:fields) { "situation_evaluation" }

    it "renders a form to edit a new `evaluation_local_habitation` with a `consistance` anomalies" do
      report = render_with_report(:evaluation_local_habitation, anomalies: %w[consistance])

      expect(page).to have_selector(".modal form") do |form|
        aggregate_failures do
          expect(form).to have_html_attribute("action").with_value("/signalements/#{report.id}")
          expect(form).to have_field("Date de mutation")
          expect(form).to have_field("Affectation")
        end
      end
    end

    it "renders a form to edit a new `evaluation_local_habitation` with a `affectation` anomalies" do
      report = render_with_report(:evaluation_local_habitation, anomalies: %w[affectation])

      expect(page).to have_selector(".modal form") do |form|
        aggregate_failures do
          expect(form).to have_html_attribute("action").with_value("/signalements/#{report.id}")
          expect(form).to have_field("Date de mutation")
          expect(form).to have_field("Affectation")
        end
      end
    end

    it "renders a form to edit a new `evaluation_local_habitation` with a `correctif` anomalies" do
      report = render_with_report(:evaluation_local_habitation, anomalies: %w[correctif])

      expect(page).to have_selector(".modal form") do |form|
        aggregate_failures do
          expect(form).to have_html_attribute("action").with_value("/signalements/#{report.id}")
          expect(form).to have_field("Date de mutation")
          expect(form).to have_field("Affectation")
        end
      end
    end

    it "renders a form to edit a new `evaluation_local_habitation` with a `exoneration` anomalies" do
      report = render_with_report(:evaluation_local_habitation, anomalies: %w[exoneration])

      expect(page).to have_selector(".modal form") do |form|
        aggregate_failures do
          expect(form).to have_html_attribute("action").with_value("/signalements/#{report.id}")
          expect(form).to have_field("Date de mutation")
          expect(form).to have_field("Affectation")
        end
      end
    end

    it "renders a form to edit a new `evaluation_local_professionnel` with a `consistance` anomalies" do
      report = render_with_report(:evaluation_local_professionnel, anomalies: %w[consistance])

      expect(page).to have_selector(".modal form") do |form|
        aggregate_failures do
          expect(form).to have_html_attribute("action").with_value("/signalements/#{report.id}")
          expect(form).to have_field("Date de mutation")
          expect(form).to have_field("Affectation")
        end
      end
    end

    it "renders a form to edit a new `evaluation_local_professionnel` with a `affectation` anomalies" do
      report = render_with_report(:evaluation_local_professionnel, anomalies: %w[affectation])

      expect(page).to have_selector(".modal form") do |form|
        aggregate_failures do
          expect(form).to have_html_attribute("action").with_value("/signalements/#{report.id}")
          expect(form).to have_field("Date de mutation")
          expect(form).to have_field("Affectation")
        end
      end
    end

    it "renders a form to edit a new `evaluation_local_professionnel` with a `categorie` anomalies" do
      report = render_with_report(:evaluation_local_professionnel, anomalies: %w[categorie])

      expect(page).to have_selector(".modal form") do |form|
        aggregate_failures do
          expect(form).to have_html_attribute("action").with_value("/signalements/#{report.id}")
          expect(form).to have_field("Date de mutation")
          expect(form).to have_field("Affectation")
        end
      end
    end

    it "renders a form to edit a new `evaluation_local_professionnel` with a `exoneration` anomalies" do
      report = render_with_report(:evaluation_local_professionnel, anomalies: %w[exoneration])

      expect(page).to have_selector(".modal form") do |form|
        aggregate_failures do
          expect(form).to have_html_attribute("action").with_value("/signalements/#{report.id}")
          expect(form).to have_field("Date de mutation")
          expect(form).to have_field("Affectation")
        end
      end
    end
  end

  describe "`proposition_evaluation` fields" do
    let(:fields) { "proposition_evaluation" }

    it "renders a form to edit a new `evaluation_local_habitation` with a `consistance` anomalies" do
      report = render_with_report(:evaluation_local_habitation, anomalies: %w[consistance])

      expect(page).to have_selector(".modal form") do |form|
        aggregate_failures do
          expect(form).to have_html_attribute("action").with_value("/signalements/#{report.id}")
          expect(form).to have_field("Nature du local")
          expect(form).to have_field("Catégorie du local")
          expect(form).to have_field("Surface réelle")
        end
      end
    end

    it "renders a form to edit a new `evaluation_local_habitation` with a `affectation` anomalies" do
      report = render_with_report(:evaluation_local_habitation, anomalies: %w[affectation])

      expect(page).to have_selector(".modal form") do |form|
        aggregate_failures do
          expect(form).to have_html_attribute("action").with_value("/signalements/#{report.id}")
          expect(form).to have_field("Affectation")
        end
      end
    end

    it "renders a form to edit a new `evaluation_local_habitation` with a `correctif` anomalies" do
      report = render_with_report(:evaluation_local_habitation, anomalies: %w[correctif])

      expect(page).to have_selector(".modal form") do |form|
        aggregate_failures do
          expect(form).to have_html_attribute("action").with_value("/signalements/#{report.id}")
          expect(form).to have_field("Coefficient d'entretien")
        end
      end
    end

    it "renders a form to edit a new `evaluation_local_professionnel` with a `consistance` anomalies" do
      report = render_with_report(:evaluation_local_professionnel, anomalies: %w[consistance])

      expect(page).to have_selector(".modal form") do |form|
        aggregate_failures do
          expect(form).to have_html_attribute("action").with_value("/signalements/#{report.id}")
          expect(form).to have_field("Catégorie du local")
          expect(form).to have_field("Surface réelle")
        end
      end
    end

    it "renders a form to edit a new `evaluation_local_professionnel` with a `affectation` anomalies" do
      report = render_with_report(:evaluation_local_professionnel, anomalies: %w[affectation])

      expect(page).to have_selector(".modal form") do |form|
        aggregate_failures do
          expect(form).to have_html_attribute("action").with_value("/signalements/#{report.id}")
          expect(form).to have_field("Affectation")
        end
      end
    end

    it "renders a form to edit a new `evaluation_local_professionnel` with a `categorie` anomalies" do
      report = render_with_report(:evaluation_local_professionnel, anomalies: %w[categorie])

      expect(page).to have_selector(".modal form") do |form|
        aggregate_failures do
          expect(form).to have_html_attribute("action").with_value("/signalements/#{report.id}")
          expect(form).to have_field("Catégorie du local")
          expect(form).to have_field("Surface réelle")
        end
      end
    end
  end

  describe "`proposition_exoneration` fields" do
    let(:fields) { "proposition_exoneration" }

    it "renders a form to edit a new `evaluation_local_habitation`" do
      report = render_with_report(:evaluation_local_habitation, anomalies: %w[exoneration])

      expect(page).to have_selector(".modal form") do |form|
        aggregate_failures do
          expect(form).to have_html_attribute("action").with_value("/signalements/#{report.id}")
          expect(form).to have_field("Action")
          expect(form).to have_field("Code d'exonération")
          expect(form).to have_field("Libellé")
        end
      end
    end

    it "renders a form to edit a new `evaluation_local_professionnel`" do
      report = render_with_report(:evaluation_local_professionnel, anomalies: %w[exoneration])

      expect(page).to have_selector(".modal form") do |form|
        aggregate_failures do
          expect(form).to have_html_attribute("action").with_value("/signalements/#{report.id}")
          expect(form).to have_field("Action")
          expect(form).to have_field("Code d'exonération")
          expect(form).to have_field("Libellé")
        end
      end
    end
  end

  describe "`proposition_adresse` fields" do
    let(:fields) { "proposition_adresse" }

    it "renders a form to edit a new `evaluation_local_habitation`" do
      report = render_with_report(:evaluation_local_habitation, anomalies: %w[adresse])

      expect(page).to have_selector(".modal form") do |form|
        aggregate_failures do
          expect(form).to have_html_attribute("action").with_value("/signalements/#{report.id}")
          expect(form).to have_field("Numéro de voie")
          expect(form).to have_field("Libellé de voie")
        end
      end
    end

    it "renders a form to edit a new `evaluation_local_professionnel`" do
      report = render_with_report(:evaluation_local_professionnel, anomalies: %w[adresse])

      expect(page).to have_selector(".modal form") do |form|
        aggregate_failures do
          expect(form).to have_html_attribute("action").with_value("/signalements/#{report.id}")
          expect(form).to have_field("Numéro de voie")
          expect(form).to have_field("Libellé de voie")
        end
      end
    end
  end

  describe "`proposition_omission_batie` fields" do
    let(:fields) { "proposition_omission_batie" }

    it "renders a form to edit a new `creation_local_habitation`" do
      report = render_with_report(:creation_local_habitation, anomalies: %w[omission_batie])

      expect(page).to have_selector(".modal form") do |form|
        aggregate_failures do
          expect(form).to have_html_attribute("action").with_value("/signalements/#{report.id}")
          expect(form).to have_field("Nature du local")
          expect(form).to have_field("Catégorie du local")
          expect(form).to have_field("Surface réelle")
        end
      end
    end

    it "renders a form to edit a new `creation_local_professionnel`" do
      report = render_with_report(:creation_local_professionnel, anomalies: %w[omission_batie])

      expect(page).to have_selector(".modal form") do |form|
        aggregate_failures do
          expect(form).to have_html_attribute("action").with_value("/signalements/#{report.id}")
          expect(form).to have_field("Nature du local")
          expect(form).to have_field("Catégorie du local")
          expect(form).to have_field("Surface réelle")
        end
      end
    end
  end

  describe "`proposition_construction_neuve` fields" do
    let(:fields) { "proposition_construction_neuve" }

    it "renders a form to edit a new `creation_local_habitation`" do
      report = render_with_report(:creation_local_habitation, anomalies: %w[construction_neuve])

      expect(page).to have_selector(".modal form") do |form|
        aggregate_failures do
          expect(form).to have_html_attribute("action").with_value("/signalements/#{report.id}")
          expect(form).to have_field("Nature du local")
          expect(form).to have_field("Catégorie du local")
          expect(form).to have_field("Surface réelle")
        end
      end
    end

    it "renders a form to edit a new `creation_local_professionnel`" do
      report = render_with_report(:creation_local_professionnel, anomalies: %w[construction_neuve])

      expect(page).to have_selector(".modal form") do |form|
        aggregate_failures do
          expect(form).to have_html_attribute("action").with_value("/signalements/#{report.id}")
          expect(form).to have_field("Nature du local")
          expect(form).to have_field("Catégorie du local")
          expect(form).to have_field("Surface réelle")
        end
      end
    end
  end
end
