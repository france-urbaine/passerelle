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

    it "renders a form to edit a new `evaluation_local_professionnel`" do
      report = render_with_report(:evaluation_local_professionnel)

      expect(page).to have_selector(".modal form") do |form|
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

    it "renders a form to edit a new `creation_local_habitation`" do
      report = render_with_report(:creation_local_habitation)

      expect(page).to have_selector(".modal form") do |form|
        expect(form).to have_html_attribute("action").with_value("/signalements/#{report.id}")
        expect(form).to have_field("Date du constat")
        expect(form).to have_field("Priorité")
        expect(form).to have_unchecked_field("Construction neuve")
        expect(form).to have_unchecked_field("Omission bâtie")
      end
    end

    it "renders a form to edit a new `creation_local_professionnel`" do
      report = render_with_report(:creation_local_professionnel)

      expect(page).to have_selector(".modal form") do |form|
        expect(form).to have_html_attribute("action").with_value("/signalements/#{report.id}")
        expect(form).to have_field("Date du constat")
        expect(form).to have_field("Priorité")
        expect(form).to have_unchecked_field("Construction neuve")
        expect(form).to have_unchecked_field("Omission bâtie")
      end
    end

    it "renders a form to edit a new `occupation_local_habitation`" do
      report = render_with_report(:occupation_local_habitation)

      expect(page).to have_selector(".modal form") do |form|
        expect(form).to have_html_attribute("action").with_value("/signalements/#{report.id}")
        expect(form).to have_field("Date du constat")
        expect(form).to have_field("Priorité")
        expect(form).to have_unchecked_field("Occupation du local")
      end
    end

    it "renders a form to edit a new `occupation_local_professionnel`" do
      report = render_with_report(:occupation_local_professionnel)

      expect(page).to have_selector(".modal form") do |form|
        expect(form).to have_html_attribute("action").with_value("/signalements/#{report.id}")
        expect(form).to have_field("Date du constat")
        expect(form).to have_field("Priorité")
        expect(form).to have_unchecked_field("Occupation du local")
      end
    end
  end

  describe "`situation_majic` fields" do
    let(:fields) { "situation_majic" }

    it "renders a form to edit a new `evaluation_local_habitation`" do
      report = render_with_report(:evaluation_local_habitation)

      expect(page).to have_selector(".modal form") do |form|
        expect(form).to have_html_attribute("action").with_value("/signalements/#{report.id}")
        expect(form).to have_field("Année du fichier MAJIC")
        expect(form).to have_field("Commune")
      end
    end

    it "renders a form to edit a new `evaluation_local_professionnel`" do
      report = render_with_report(:evaluation_local_professionnel)

      expect(page).to have_selector(".modal form") do |form|
        expect(form).to have_html_attribute("action").with_value("/signalements/#{report.id}")
        expect(form).to have_field("Année du fichier MAJIC")
        expect(form).to have_field("Commune")
      end
    end
  end

  describe "`situation_parcelle` fields" do
    let(:fields) { "situation_parcelle" }

    it "renders a form to edit a new `creation_local_habitation`" do
      report = render_with_report(:creation_local_habitation)

      expect(page).to have_selector(".modal form") do |form|
        expect(form).to have_html_attribute("action").with_value("/signalements/#{report.id}")
        expect(form).to have_field("Commune")
        expect(form).to have_field("Parcelle")
      end
    end

    it "renders a form to edit a new `creation_local_professionnel`" do
      report = render_with_report(:creation_local_professionnel)

      expect(page).to have_selector(".modal form") do |form|
        expect(form).to have_html_attribute("action").with_value("/signalements/#{report.id}")
        expect(form).to have_field("Commune")
        expect(form).to have_field("Parcelle")
      end
    end
  end

  describe "`situation_evaluation` fields" do
    let(:fields) { "situation_evaluation" }

    it "renders a form to edit a new `evaluation_local_habitation` with a `consistance` anomalies" do
      report = render_with_report(:evaluation_local_habitation, anomalies: %w[consistance])

      expect(page).to have_selector(".modal form") do |form|
        expect(form).to have_html_attribute("action").with_value("/signalements/#{report.id}")
        expect(form).to have_field("Date de mutation")
        expect(form).to have_field("Affectation")
      end
    end

    it "renders a form to edit a new `evaluation_local_habitation` with a `affectation` anomalies" do
      report = render_with_report(:evaluation_local_habitation, anomalies: %w[affectation])

      expect(page).to have_selector(".modal form") do |form|
        expect(form).to have_html_attribute("action").with_value("/signalements/#{report.id}")
        expect(form).to have_field("Date de mutation")
        expect(form).to have_field("Affectation")
      end
    end

    it "renders a form to edit a new `evaluation_local_habitation` with a `correctif` anomalies" do
      report = render_with_report(:evaluation_local_habitation, anomalies: %w[correctif])

      expect(page).to have_selector(".modal form") do |form|
        expect(form).to have_html_attribute("action").with_value("/signalements/#{report.id}")
        expect(form).to have_field("Date de mutation")
        expect(form).to have_field("Affectation")
      end
    end

    it "renders a form to edit a new `evaluation_local_habitation` with a `exoneration` anomalies" do
      report = render_with_report(:evaluation_local_habitation, anomalies: %w[exoneration])

      expect(page).to have_selector(".modal form") do |form|
        expect(form).to have_html_attribute("action").with_value("/signalements/#{report.id}")
        expect(form).to have_field("Date de mutation")
        expect(form).to have_field("Affectation")
      end
    end

    it "renders a form to edit a new `evaluation_local_professionnel` with a `consistance` anomalies" do
      report = render_with_report(:evaluation_local_professionnel, anomalies: %w[consistance])

      expect(page).to have_selector(".modal form") do |form|
        expect(form).to have_html_attribute("action").with_value("/signalements/#{report.id}")
        expect(form).to have_field("Date de mutation")
        expect(form).to have_field("Affectation")
      end
    end

    it "renders a form to edit a new `evaluation_local_professionnel` with a `affectation` anomalies" do
      report = render_with_report(:evaluation_local_professionnel, anomalies: %w[affectation])

      expect(page).to have_selector(".modal form") do |form|
        expect(form).to have_html_attribute("action").with_value("/signalements/#{report.id}")
        expect(form).to have_field("Date de mutation")
        expect(form).to have_field("Affectation")
      end
    end

    it "renders a form to edit a new `evaluation_local_professionnel` with a `categorie` anomalies" do
      report = render_with_report(:evaluation_local_professionnel, anomalies: %w[categorie])

      expect(page).to have_selector(".modal form") do |form|
        expect(form).to have_html_attribute("action").with_value("/signalements/#{report.id}")
        expect(form).to have_field("Date de mutation")
        expect(form).to have_field("Affectation")
      end
    end

    it "renders a form to edit a new `evaluation_local_professionnel` with a `exoneration` anomalies" do
      report = render_with_report(:evaluation_local_professionnel, anomalies: %w[exoneration])

      expect(page).to have_selector(".modal form") do |form|
        expect(form).to have_html_attribute("action").with_value("/signalements/#{report.id}")
        expect(form).to have_field("Date de mutation")
        expect(form).to have_field("Affectation")
      end
    end

    it "renders a form to edit a new `occupation_local_habitation` with a `occupation` anomalies" do
      report = render_with_report(:occupation_local_habitation, anomalies: %w[occupation])

      expect(page).to have_selector(".modal form") do |form|
        expect(form).to have_html_attribute("action").with_value("/signalements/#{report.id}")
        expect(form).to have_field("Affectation")
        expect(form).to have_field("Nature du local")
        expect(form).to have_field("Catégorie du local")
      end
    end

    it "renders a form to edit a new `occupation_local_professionnel` with a `occupation` anomalies" do
      report = render_with_report(:occupation_local_professionnel, anomalies: %w[occupation])

      expect(page).to have_selector(".modal form") do |form|
        expect(form).to have_html_attribute("action").with_value("/signalements/#{report.id}")
        expect(form).to have_field("Affectation")
        expect(form).to have_field("Nature du local")
        expect(form).to have_field("Catégorie du local")
        expect(form).to have_field("Surface réelle")
      end
    end
  end

  describe "`situation_occupation` fields" do
    let(:fields) { "situation_occupation" }

    it "renders a form to edit a new `occupation_local_habitation` with a `occupation` anomalies" do
      report = render_with_report(:occupation_local_habitation, anomalies: %w[occupation])

      expect(page).to have_selector(".modal form") do |form|
        expect(form).to have_html_attribute("action").with_value("/signalements/#{report.id}")
        expect(form).to have_field("Année du fichier d'occupation")
        expect(form).to have_field("Nature de l'occupation")
      end
    end

    it "renders a form to edit a new `occupation_local_professionnel` with a `occupation` anomalies" do
      report = render_with_report(:occupation_local_professionnel, anomalies: %w[occupation])

      expect(page).to have_selector(".modal form") do |form|
        expect(form).to have_html_attribute("action").with_value("/signalements/#{report.id}")
        expect(form).to have_field("Année du fichier CFE")
        expect(form).to have_field("Vacance fiscale")
        expect(form).to have_field("N° SIREN du dernier occupant")
        expect(form).to have_field("Nom du dernier occupant")
        expect(form).to have_field("VLF Cotisation foncière des entreprises")
        expect(form).to have_field("Taxation base minimum")
      end
    end
  end

  describe "`proposition_evaluation` fields" do
    let(:fields) { "proposition_evaluation" }

    it "renders a form to edit a new `evaluation_local_habitation` with a `consistance` anomalies" do
      report = render_with_report(:evaluation_local_habitation, anomalies: %w[consistance])

      expect(page).to have_selector(".modal form") do |form|
        expect(form).to have_html_attribute("action").with_value("/signalements/#{report.id}")
        expect(form).to have_field("Nature du local")
        expect(form).to have_field("Catégorie du local")
        expect(form).to have_field("Surface réelle")
      end
    end

    it "renders a form to edit a new `evaluation_local_habitation` with a `affectation` anomalies" do
      report = render_with_report(:evaluation_local_habitation, anomalies: %w[affectation])

      expect(page).to have_selector(".modal form") do |form|
        expect(form).to have_html_attribute("action").with_value("/signalements/#{report.id}")
        expect(form).to have_field("Affectation")
      end
    end

    it "renders a form to edit a new `evaluation_local_habitation` with a `correctif` anomalies" do
      report = render_with_report(:evaluation_local_habitation, anomalies: %w[correctif])

      expect(page).to have_selector(".modal form") do |form|
        expect(form).to have_html_attribute("action").with_value("/signalements/#{report.id}")
        expect(form).to have_field("Coefficient d'entretien")
      end
    end

    it "renders a form to edit a new `evaluation_local_professionnel` with a `consistance` anomalies" do
      report = render_with_report(:evaluation_local_professionnel, anomalies: %w[consistance])

      expect(page).to have_selector(".modal form") do |form|
        expect(form).to have_html_attribute("action").with_value("/signalements/#{report.id}")
        expect(form).to have_field("Catégorie du local")
        expect(form).to have_field("Surface réelle")
      end
    end

    it "renders a form to edit a new `evaluation_local_professionnel` with a `affectation` anomalies" do
      report = render_with_report(:evaluation_local_professionnel, anomalies: %w[affectation])

      expect(page).to have_selector(".modal form") do |form|
        expect(form).to have_html_attribute("action").with_value("/signalements/#{report.id}")
        expect(form).to have_field("Affectation")
      end
    end

    it "renders a form to edit a new `evaluation_local_professionnel` with a `categorie` anomalies" do
      report = render_with_report(:evaluation_local_professionnel, anomalies: %w[categorie])

      expect(page).to have_selector(".modal form") do |form|
        expect(form).to have_html_attribute("action").with_value("/signalements/#{report.id}")
        expect(form).to have_field("Catégorie du local")
        expect(form).to have_field("Surface réelle")
      end
    end
  end

  describe "`proposition_exoneration` fields" do
    let(:fields) { "proposition_exoneration" }

    it "renders a form to edit a new `evaluation_local_habitation`" do
      report = render_with_report(:evaluation_local_habitation, anomalies: %w[exoneration])

      expect(page).to have_selector(".modal form") do |form|
        expect(form).to have_html_attribute("action").with_value("/signalements/#{report.id}")
        expect(form).to have_field("Action")
        expect(form).to have_field("Code d'exonération")
        expect(form).to have_field("Libellé")
      end
    end

    it "renders a form to edit a new `evaluation_local_professionnel`" do
      report = render_with_report(:evaluation_local_professionnel, anomalies: %w[exoneration])

      expect(page).to have_selector(".modal form") do |form|
        expect(form).to have_html_attribute("action").with_value("/signalements/#{report.id}")
        expect(form).to have_field("Action")
        expect(form).to have_field("Code d'exonération")
        expect(form).to have_field("Libellé")
      end
    end
  end

  describe "`proposition_adresse` fields" do
    let(:fields) { "proposition_adresse" }

    it "renders a form to edit a new `evaluation_local_habitation`" do
      report = render_with_report(:evaluation_local_habitation, anomalies: %w[adresse])

      expect(page).to have_selector(".modal form") do |form|
        expect(form).to have_html_attribute("action").with_value("/signalements/#{report.id}")
        expect(form).to have_field("Numéro de voie")
        expect(form).to have_field("Libellé de voie")
      end
    end

    it "renders a form to edit a new `evaluation_local_professionnel`" do
      report = render_with_report(:evaluation_local_professionnel, anomalies: %w[adresse])

      expect(page).to have_selector(".modal form") do |form|
        expect(form).to have_html_attribute("action").with_value("/signalements/#{report.id}")
        expect(form).to have_field("Numéro de voie")
        expect(form).to have_field("Libellé de voie")
      end
    end
  end

  describe "`proposition_creation_local` fields" do
    let(:fields) { "proposition_creation_local" }

    it "renders a form to edit a new `creation_local_habitation` with a `construction_neuve` anomalies" do
      report = render_with_report(:creation_local_habitation, anomalies: %w[construction_neuve])

      expect(page).to have_selector(".modal form") do |form|
        expect(form).to have_html_attribute("action").with_value("/signalements/#{report.id}")
        expect(form).to have_field("Nature du local")
        expect(form).to have_field("Catégorie du local")
        expect(form).to have_field("Surface réelle")
      end
    end

    it "renders a form to edit a new `creation_local_professionnel` with a `construction_neuve` anomalies" do
      report = render_with_report(:creation_local_professionnel, anomalies: %w[construction_neuve])

      expect(page).to have_selector(".modal form") do |form|
        expect(form).to have_html_attribute("action").with_value("/signalements/#{report.id}")
        expect(form).to have_field("Nature du local")
        expect(form).to have_field("Catégorie du local")
        expect(form).to have_field("Surface réelle")
      end
    end

    it "renders a form to edit a new `creation_local_habitation` with a `omission_batie` anomalies" do
      report = render_with_report(:creation_local_habitation, anomalies: %w[omission_batie])

      expect(page).to have_selector(".modal form") do |form|
        expect(form).to have_html_attribute("action").with_value("/signalements/#{report.id}")
        expect(form).to have_field("Nature du local")
        expect(form).to have_field("Catégorie du local")
        expect(form).to have_field("Surface réelle")
      end
    end

    it "renders a form to edit a new `creation_local_professionnel` with a `omission_batie` anomalies" do
      report = render_with_report(:creation_local_professionnel, anomalies: %w[omission_batie])

      expect(page).to have_selector(".modal form") do |form|
        expect(form).to have_html_attribute("action").with_value("/signalements/#{report.id}")
        expect(form).to have_field("Nature du local")
        expect(form).to have_field("Catégorie du local")
        expect(form).to have_field("Surface réelle")
      end
    end
  end

  describe "`proposition_occupation` fields" do
    let(:fields) { "proposition_occupation" }

    it "renders a form to edit a new `occupation_local_habitation` with a `occupation` anomalies" do
      report = render_with_report(:occupation_local_habitation, anomalies: %w[occupation])

      expect(page).to have_selector(".modal form") do |form|
        expect(form).to have_html_attribute("action").with_value("/signalements/#{report.id}")
        expect(form).to have_field("Date du changement")
        expect(form).to have_field("Nature de l'occupation")
      end
    end

    it "renders a form to edit a new `occupation_local_professionnel` with a `occupation` anomalies" do
      report = render_with_report(:occupation_local_professionnel, anomalies: %w[occupation])

      expect(page).to have_selector(".modal form") do |form|
        expect(form).to have_html_attribute("action").with_value("/signalements/#{report.id}")
        expect(form).to have_field("N° SIREN")
        expect(form).to have_field("Nom de l'entreprise")
        expect(form).to have_field("Enseigne")
        expect(form).to have_field("Etablissement principal")
        expect(form).to have_field("Chantier longue durée")
        expect(form).to have_field("Code NAF")
        expect(form).to have_field("Date de début de l'activité")
      end
    end
  end
end
