# frozen_string_literal: true

require "rails_helper"

RSpec.describe Reports::CheckCompletenessService do
  subject(:check_completeness_service) do
    described_class.new(report)
  end

  def inspect_errors(report)
    service = described_class.new(report)
    ap(service.errors.details) unless service.valid?
  end

  # TODO: more test cases are required

  context "with an evaluation_local_habitation" do
    it "validates an 'affectaction' anomaly after setting proposition_affectation to professionnal" do
      report = build_stubbed(
        :report,
        form_type:                            "evaluation_local_habitation",
        anomalies:                            %w[affectation],
        date_constat:                         "2024-04-01",
        code_insee:                           "64102",
        situation_annee_majic:                2024,
        situation_invariant:                  "0123456789",
        situation_parcelle:                   "AB 0001",
        situation_libelle_voie:               "RUE CLEMENCEAU",
        situation_code_rivoli:                "0023",
        situation_numero_batiment:            "A",
        situation_numero_escalier:            "1",
        situation_numero_niveau:              "1",
        situation_numero_porte:               "22",
        situation_numero_ordre_porte:         "001",
        situation_proprietaire:               "MARCEL DUCHAMPS",
        situation_numero_ordre_proprietaire:  "* 02465",
        situation_date_mutation:              "2014-02",
        situation_affectation:                "H",
        situation_nature:                     "MA",
        situation_categorie:                  "4",
        situation_surface_reelle:             102.00,
        situation_coefficient_entretien:      "1.2",
        proposition_affectation:              "C",
        proposition_nature:                   "CB",
        proposition_categorie:                "MAG1",
        proposition_surface_reelle:           110.00,
        proposition_coefficient_localisation: 1.15
      )

      expect(described_class.new(report)).to be_valid
    end

    it "validates an 'affectaction' anomaly after setting proposition_affectation to industrial" do
      report = build_stubbed(
        :report,
        form_type:                            "evaluation_local_habitation",
        anomalies:                            %w[affectation],
        date_constat:                         "2024-04-01",
        code_insee:                           "64102",
        situation_annee_majic:                2024,
        situation_invariant:                  "0123456789",
        situation_parcelle:                   "AB 0001",
        situation_libelle_voie:               "RUE CLEMENCEAU",
        situation_code_rivoli:                "0023",
        situation_numero_batiment:            "A",
        situation_numero_escalier:            "1",
        situation_numero_niveau:              "1",
        situation_numero_porte:               "22",
        situation_numero_ordre_porte:         "001",
        situation_proprietaire:               "MARCEL DUCHAMPS",
        situation_numero_ordre_proprietaire:  "* 02465",
        situation_date_mutation:              "2014-02",
        situation_affectation:                "H",
        situation_nature:                     "MA",
        situation_categorie:                  "4",
        situation_surface_reelle:             102.00,
        situation_coefficient_entretien:      "1.2",
        proposition_affectation:              "B",
        proposition_nature:                   "U"
      )

      expect(described_class.new(report)).to be_valid
    end

    it "validates an 'exoneration' anomaly" do
      report = build_stubbed(
        :report,
        form_type:                            "evaluation_local_habitation",
        anomalies:                            %w[exoneration],
        date_constat:                         "2024-04-01",
        code_insee:                           "64102",
        situation_annee_majic:                2024,
        situation_invariant:                  "0123456789",
        situation_parcelle:                   "AB 0001",
        situation_libelle_voie:               "RUE CLEMENCEAU",
        situation_code_rivoli:                "0023",
        situation_numero_batiment:            "A",
        situation_numero_escalier:            "1",
        situation_numero_niveau:              "1",
        situation_numero_porte:               "22",
        situation_numero_ordre_porte:         "001",
        situation_proprietaire:               "MARCEL DUCHAMPS",
        situation_numero_ordre_proprietaire:  "* 02465",
        situation_date_mutation:              "2014-02",
        situation_affectation:                "H",
        situation_nature:                     "MA",
        situation_categorie:                  "4",
        situation_surface_reelle:             102.00,
        situation_coefficient_entretien:      "1.2",
        exonerations_attributes:              [
          {
            status:            "supprimer",
            code:              "AD",
            label:             "Droit commun (2 ans) - addition de construction",
            base:              "imposable",
            code_collectivite: "GC"
          }
        ]
      )

      expect(described_class.new(report)).to be_valid
    end

    it "validates an 'adresse' anomaly" do
      report = build_stubbed(
        :report,
        form_type:                            "evaluation_local_habitation",
        anomalies:                            %w[adresse],
        date_constat:                         "2024-04-01",
        code_insee:                           "64102",
        situation_annee_majic:                2024,
        situation_invariant:                  "0123456789",
        situation_parcelle:                   "AB 0001",
        situation_libelle_voie:               "RUE CLEMENCEAU",
        situation_code_rivoli:                "0023",
        situation_numero_batiment:            "A",
        situation_numero_escalier:            "1",
        situation_numero_niveau:              "1",
        situation_numero_porte:               "22",
        situation_numero_ordre_porte:         "001",
        situation_proprietaire:               "MARCEL DUCHAMPS",
        situation_numero_ordre_proprietaire:  "* 02465",
        proposition_libelle_voie:             "RUE GEORGES CLEMENCEAU"
      )

      expect(described_class.new(report)).to be_valid
    end
  end

  context "with an evaluation_local_professionnel" do
    it "validates an 'affectaction' anomaly after setting proposition_affectation to professionnal" do
      report = build_stubbed(
        :report,
        form_type:                            "evaluation_local_professionnel",
        anomalies:                            %w[affectation],
        date_constat:                         "2024-04-01",
        code_insee:                           "64102",
        situation_annee_majic:                2024,
        situation_invariant:                  "0123456789",
        situation_parcelle:                   "AB 0001",
        situation_libelle_voie:               "RUE CLEMENCEAU",
        situation_code_rivoli:                "0023",
        situation_numero_batiment:            "A",
        situation_numero_escalier:            "1",
        situation_numero_niveau:              "1",
        situation_numero_porte:               "22",
        situation_numero_ordre_porte:         "001",
        situation_proprietaire:               "MARCEL DUCHAMPS",
        situation_numero_ordre_proprietaire:  "* 02465",
        situation_date_mutation:              "2014-02",
        situation_affectation:                "C",
        situation_nature:                     "CB",
        situation_categorie:                  "MAG1",
        situation_surface_reelle:             240.00,
        situation_coefficient_localisation:   1.15,
        proposition_affectation:              "L",
        proposition_nature:                   "CB",
        proposition_categorie:                "HOT2",
        proposition_surface_reelle:           240.00,
        proposition_coefficient_localisation: 1.15
      )

      expect(described_class.new(report)).to be_valid
    end

    it "validates an 'affectaction' anomaly after setting proposition_affectation to habitation" do
      report = build_stubbed(
        :report,
        form_type:                            "evaluation_local_professionnel",
        anomalies:                            %w[affectation],
        date_constat:                         "2024-04-01",
        code_insee:                           "64102",
        situation_annee_majic:                2024,
        situation_invariant:                  "0123456789",
        situation_parcelle:                   "AB 0001",
        situation_libelle_voie:               "RUE CLEMENCEAU",
        situation_code_rivoli:                "0023",
        situation_numero_batiment:            "A",
        situation_numero_escalier:            "1",
        situation_numero_niveau:              "1",
        situation_numero_porte:               "22",
        situation_numero_ordre_porte:         "001",
        situation_proprietaire:               "MARCEL DUCHAMPS",
        situation_numero_ordre_proprietaire:  "* 02465",
        situation_date_mutation:              "2014-02",
        situation_affectation:                "C",
        situation_nature:                     "CB",
        situation_categorie:                  "MAG1",
        situation_surface_reelle:             240.00,
        situation_coefficient_localisation:   1.15,
        proposition_affectation:              "H",
        proposition_nature:                   "MA",
        proposition_categorie:                "5",
        proposition_surface_reelle:           240.00,
        proposition_coefficient_entretien:    1.20
      )

      expect(described_class.new(report)).to be_valid
    end

    it "validates an 'affectation' anomaly after setting proposition_affectation to habitation and nature to dependance" do
      report = build_stubbed(
        :report,
        form_type:                            "evaluation_local_professionnel",
        anomalies:                            %w[affectation],
        date_constat:                         "2024-04-01",
        code_insee:                           "64102",
        situation_annee_majic:                2024,
        situation_invariant:                  "0123456789",
        situation_parcelle:                   "AB 0001",
        situation_libelle_voie:               "RUE CLEMENCEAU",
        situation_code_rivoli:                "0023",
        situation_numero_batiment:            "A",
        situation_numero_escalier:            "1",
        situation_numero_niveau:              "1",
        situation_numero_porte:               "22",
        situation_numero_ordre_porte:         "001",
        situation_proprietaire:               "MARCEL DUCHAMPS",
        situation_numero_ordre_proprietaire:  "* 02465",
        situation_date_mutation:              "2014-02",
        situation_affectation:                "C",
        situation_nature:                     "CB",
        situation_categorie:                  "MAG1",
        situation_surface_reelle:             240.00,
        situation_coefficient_localisation:   1.15,
        proposition_affectation:              "H",
        proposition_nature:                   "DA",
        proposition_nature_dependance:        "BC",
        proposition_categorie:                "AM",
        proposition_surface_reelle:           240.00,
        proposition_coefficient_entretien:    1.20
      )

      expect(described_class.new(report)).to be_valid
    end

    it "validates an 'exoneration' anomaly" do
      report = build_stubbed(
        :report,
        form_type:                            "evaluation_local_professionnel",
        anomalies:                            %w[exoneration],
        date_constat:                         "2024-04-01",
        code_insee:                           "64102",
        situation_annee_majic:                2024,
        situation_invariant:                  "0123456789",
        situation_parcelle:                   "AB 0001",
        situation_libelle_voie:               "RUE CLEMENCEAU",
        situation_code_rivoli:                "0023",
        situation_numero_batiment:            "A",
        situation_numero_escalier:            "1",
        situation_numero_niveau:              "1",
        situation_numero_porte:               "22",
        situation_numero_ordre_porte:         "001",
        situation_proprietaire:               "MARCEL DUCHAMPS",
        situation_numero_ordre_proprietaire:  "* 02465",
        situation_date_mutation:              "2014-02",
        situation_affectation:                "C",
        situation_nature:                     "CB",
        situation_categorie:                  "MAG1",
        situation_surface_reelle:             240.00,
        situation_coefficient_localisation:   1.15,
        exonerations_attributes:              [
          {
            status:            "supprimer",
            code:              "AD",
            label:             "Droit commun (2 ans) - addition de construction",
            base:              "imposable",
            code_collectivite: "GC"
          }
        ]
      )

      # inspect_errors(report)

      expect(described_class.new(report)).to be_valid
    end

    it "validates an 'adresse' anomaly" do
      report = build_stubbed(
        :report,
        form_type:                            "evaluation_local_professionnel",
        anomalies:                            %w[adresse],
        date_constat:                         "2024-04-01",
        code_insee:                           "64102",
        situation_annee_majic:                2024,
        situation_invariant:                  "0123456789",
        situation_parcelle:                   "AB 0001",
        situation_libelle_voie:               "RUE CLEMENCEAU",
        situation_code_rivoli:                "0023",
        situation_numero_batiment:            "A",
        situation_numero_escalier:            "1",
        situation_numero_niveau:              "1",
        situation_numero_porte:               "22",
        situation_numero_ordre_porte:         "001",
        situation_proprietaire:               "MARCEL DUCHAMPS",
        situation_numero_ordre_proprietaire:  "* 02465",
        proposition_libelle_voie:             "RUE GEORGES CLEMENCEAU"
      )

      expect(described_class.new(report)).to be_valid
    end
  end

  context "with a creation_local_habitation" do
    it "validates an 'omission_batie' anomaly with nature set to habitation" do
      report = build_stubbed(
        :report,
        form_type:                            "creation_local_habitation",
        anomalies:                            %w[omission_batie],
        date_constat:                         "2024-04-01",
        code_insee:                           "64102",
        situation_parcelle:                   "AB 0001",
        situation_libelle_voie:               "RUE CLEMENCEAU",
        situation_code_rivoli:                "0023",
        situation_proprietaire:               "MARCEL DUCHAMPS",
        situation_numero_ordre_proprietaire:  "* 02465",
        proposition_nature:                   "MA",
        proposition_categorie:                "4",
        proposition_surface_reelle:           98.00,
        proposition_date_achevement:          "2023-12-10"
      )

      expect(described_class.new(report)).to be_valid
    end

    it "validates an 'omission_batie' anomaly with nature set to dependance" do
      report = build_stubbed(
        :report,
        form_type:                            "creation_local_habitation",
        anomalies:                            %w[omission_batie],
        date_constat:                         "2024-04-01",
        code_insee:                           "64102",
        situation_parcelle:                   "AB 0001",
        situation_libelle_voie:               "RUE CLEMENCEAU",
        situation_code_rivoli:                "0023",
        situation_proprietaire:               "MARCEL DUCHAMPS",
        situation_numero_ordre_proprietaire:  "* 02465",
        proposition_nature:                   "DA",
        proposition_nature_dependance:        "GA",
        proposition_categorie:                "A",
        proposition_surface_reelle:           98.00,
        proposition_date_achevement:          "2023-12-10"
      )

      expect(described_class.new(report)).to be_valid
    end
  end
end
