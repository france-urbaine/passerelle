# frozen_string_literal: true

require "rails_helper"

RSpec.describe Reports::RequirementsService do
  subject(:requirements_service) do
    described_class.new(report)
  end

  context "with an evaluation_local_habitation" do
    context "without any anomalies" do
      let(:report) do
        build_stubbed(:report, form_type: "evaluation_local_habitation")
      end

      # Situation MAJIC
      it { is_expected.to be_display_situation_majic }
      it { is_expected.to be_display_situation_annee_majic }
      it { is_expected.to be_display_situation_invariant }
      it { is_expected.to be_display_situation_parcelle }
      it { is_expected.to be_display_situation_adresse }
      it { is_expected.to be_display_situation_porte }
      it { is_expected.to be_display_situation_proprietaire }

      it { is_expected.to be_require_situation_annee_majic }
      it { is_expected.to be_require_situation_invariant }
      it { is_expected.to be_require_situation_parcelle }
      it { is_expected.to be_require_situation_adresse }
      it { is_expected.to be_require_situation_porte }
      it { is_expected.to be_require_situation_proprietaire }

      # Others
      it { is_expected.not_to be_display_situation_evaluation }
      it { is_expected.not_to be_display_situation_occupation }
      it { is_expected.not_to be_display_proposition_evaluation }
      it { is_expected.not_to be_display_proposition_creation_local }
      it { is_expected.not_to be_display_proposition_occupation }
      it { is_expected.not_to be_display_proposition_exoneration }
      it { is_expected.not_to be_display_proposition_adresse }
    end

    context "with an 'affectaction' anomaly" do
      let(:report) do
        build_stubbed(:report,
          form_type: "evaluation_local_habitation",
          anomalies: %w[affectation])
      end

      # Situation evaluation
      it { is_expected.to     be_display_situation_evaluation }
      it { is_expected.to     be_display_situation_date_mutation }
      it { is_expected.to     be_display_situation_affectation }
      it { is_expected.to     be_display_situation_nature }
      it { is_expected.to     be_display_situation_categorie }
      it { is_expected.to     be_display_situation_surface_reelle }
      it { is_expected.not_to be_display_other_situation_surface }
      it { is_expected.not_to be_display_situation_coefficient_localisation }
      it { is_expected.to     be_display_situation_coefficient_entretien }
      it { is_expected.to     be_display_situation_coefficient_situation }

      it { is_expected.to     be_require_situation_date_mutation }
      it { is_expected.to     be_require_situation_affectation }
      it { is_expected.to     be_require_situation_nature }
      it { is_expected.to     be_require_situation_categorie }
      it { is_expected.to     be_require_situation_surface_reelle }
      it { is_expected.not_to be_require_situation_coefficient_localisation }
      it { is_expected.to     be_require_situation_coefficient_entretien }

      it { is_expected.to     be_expect_situation_nature_habitation }
      it { is_expected.not_to be_expect_situation_nature_professionnel }
      it { is_expected.to     be_expect_situation_categorie_habitation }
      it { is_expected.not_to be_expect_situation_categorie_professionnel }

      # Proposition evaluation
      it { is_expected.to     be_display_proposition_evaluation }
      it { is_expected.to     be_display_proposition_affectation }
      it { is_expected.to     be_display_proposition_nature }
      it { is_expected.not_to be_display_proposition_nature_dependance }
      it { is_expected.to     be_display_proposition_categorie }
      it { is_expected.to     be_display_proposition_surface_reelle }
      it { is_expected.not_to be_display_other_proposition_surface }
      it { is_expected.not_to be_display_proposition_coefficient_localisation }
      it { is_expected.not_to be_display_proposition_coefficient_entretien }
      it { is_expected.not_to be_display_proposition_coefficient_situation }

      it { is_expected.to     be_require_proposition_affectation }
      it { is_expected.to     be_require_proposition_nature }
      it { is_expected.not_to be_require_proposition_nature_dependance }
      it { is_expected.to     be_require_proposition_categorie }
      it { is_expected.to     be_require_proposition_surface_reelle }
      it { is_expected.not_to be_require_proposition_coefficient_localisation }
      it { is_expected.not_to be_require_proposition_coefficient_entretien }

      it { is_expected.not_to be_expect_proposition_nature_habitation }
      it { is_expected.not_to be_expect_proposition_nature_professionnel }
      it { is_expected.not_to be_expect_proposition_nature_creation_local_habitation }
      it { is_expected.not_to be_expect_proposition_categorie_habitation }
      it { is_expected.not_to be_expect_proposition_categorie_dependance }
      it { is_expected.not_to be_expect_proposition_categorie_professionnel }

      # Others
      it { is_expected.not_to be_display_situation_occupation }
      it { is_expected.not_to be_display_proposition_creation_local }
      it { is_expected.not_to be_display_proposition_occupation }
      it { is_expected.not_to be_display_proposition_exoneration }
      it { is_expected.not_to be_display_proposition_adresse }

      it { is_expected.not_to be_require_proposition_exoneration }
      it { is_expected.not_to be_require_proposition_adresse }

      context "when setting proposition_affectation to professionnal" do
        let(:report) do
          build_stubbed(:report,
            form_type: "evaluation_local_habitation",
            anomalies: %w[affectation],
            proposition_affectation: "C")
        end

        # Proposition evaluation
        it { is_expected.to     be_display_proposition_evaluation }
        it { is_expected.to     be_display_proposition_affectation }
        it { is_expected.to     be_display_proposition_nature }
        it { is_expected.not_to be_display_proposition_nature_dependance }
        it { is_expected.to     be_display_proposition_categorie }
        it { is_expected.to     be_display_proposition_surface_reelle }
        it { is_expected.to     be_display_other_proposition_surface }
        it { is_expected.to     be_display_proposition_coefficient_localisation }
        it { is_expected.not_to be_display_proposition_coefficient_entretien }
        it { is_expected.not_to be_display_proposition_coefficient_situation }

        it { is_expected.to     be_require_proposition_affectation }
        it { is_expected.to     be_require_proposition_nature }
        it { is_expected.not_to be_require_proposition_nature_dependance }
        it { is_expected.to     be_require_proposition_categorie }
        it { is_expected.to     be_require_proposition_surface_reelle }
        it { is_expected.to     be_require_proposition_coefficient_localisation }
        it { is_expected.not_to be_require_proposition_coefficient_entretien }

        it { is_expected.not_to be_expect_proposition_nature_habitation }
        it { is_expected.to     be_expect_proposition_nature_professionnel }
        it { is_expected.not_to be_expect_proposition_nature_creation_local_habitation }
        it { is_expected.not_to be_expect_proposition_categorie_habitation }
        it { is_expected.not_to be_expect_proposition_categorie_dependance }
        it { is_expected.to     be_expect_proposition_categorie_professionnel }

        # Others
        it { is_expected.not_to be_display_situation_occupation }
        it { is_expected.not_to be_display_proposition_creation_local }
        it { is_expected.not_to be_display_proposition_occupation }
        it { is_expected.not_to be_display_proposition_exoneration }
        it { is_expected.not_to be_display_proposition_adresse }

        it { is_expected.not_to be_require_proposition_exoneration }
        it { is_expected.not_to be_require_proposition_adresse }
      end

      context "when setting proposition_nature set to industrial" do
        let(:report) do
          build_stubbed(:report,
            form_type: "evaluation_local_habitation",
            anomalies: %w[affectation],
            proposition_affectation: "B",
            proposition_nature:      "U")
        end

        # Proposition evaluation
        it { is_expected.to     be_display_proposition_evaluation }
        it { is_expected.to     be_display_proposition_affectation }
        it { is_expected.to     be_display_proposition_nature }
        it { is_expected.not_to be_display_proposition_nature_dependance }
        it { is_expected.to     be_display_proposition_categorie }
        it { is_expected.to     be_display_proposition_surface_reelle }
        it { is_expected.to     be_display_other_proposition_surface }
        it { is_expected.to     be_display_proposition_coefficient_localisation }
        it { is_expected.not_to be_display_proposition_coefficient_entretien }
        it { is_expected.not_to be_display_proposition_coefficient_situation }

        it { is_expected.to     be_require_proposition_affectation }
        it { is_expected.to     be_require_proposition_nature }
        it { is_expected.not_to be_require_proposition_nature_dependance }
        it { is_expected.not_to be_require_proposition_categorie }
        it { is_expected.not_to be_require_proposition_surface_reelle }
        it { is_expected.not_to be_require_proposition_coefficient_localisation }
        it { is_expected.not_to be_require_proposition_coefficient_entretien }

        it { is_expected.not_to be_expect_proposition_nature_habitation }
        it { is_expected.to     be_expect_proposition_nature_professionnel }
        it { is_expected.not_to be_expect_proposition_nature_creation_local_habitation }
        it { is_expected.not_to be_expect_proposition_categorie_habitation }
        it { is_expected.not_to be_expect_proposition_categorie_dependance }
        it { is_expected.to     be_expect_proposition_categorie_professionnel }

        # Others
        it { is_expected.not_to be_display_situation_occupation }
        it { is_expected.not_to be_display_proposition_creation_local }
        it { is_expected.not_to be_display_proposition_occupation }
        it { is_expected.not_to be_display_proposition_exoneration }
        it { is_expected.not_to be_display_proposition_adresse }

        it { is_expected.not_to be_require_proposition_exoneration }
        it { is_expected.not_to be_require_proposition_adresse }
      end
    end

    context "with a 'consistance' anomaly" do
      let(:report) do
        build_stubbed(:report,
          form_type: "evaluation_local_habitation",
          anomalies: %w[consistance])
      end

      # Situation evaluation
      it { is_expected.to     be_display_situation_evaluation }
      it { is_expected.to     be_display_situation_date_mutation }
      it { is_expected.to     be_display_situation_affectation }
      it { is_expected.to     be_display_situation_nature }
      it { is_expected.to     be_display_situation_categorie }
      it { is_expected.to     be_display_situation_surface_reelle }
      it { is_expected.not_to be_display_other_situation_surface }
      it { is_expected.not_to be_display_situation_coefficient_localisation }
      it { is_expected.to     be_display_situation_coefficient_entretien }
      it { is_expected.to     be_display_situation_coefficient_situation }

      it { is_expected.to     be_require_situation_date_mutation }
      it { is_expected.to     be_require_situation_affectation }
      it { is_expected.to     be_require_situation_nature }
      it { is_expected.to     be_require_situation_categorie }
      it { is_expected.to     be_require_situation_surface_reelle }
      it { is_expected.not_to be_require_situation_coefficient_localisation }
      it { is_expected.to     be_require_situation_coefficient_entretien }

      it { is_expected.to     be_expect_situation_nature_habitation }
      it { is_expected.not_to be_expect_situation_nature_professionnel }
      it { is_expected.to     be_expect_situation_categorie_habitation }
      it { is_expected.not_to be_expect_situation_categorie_professionnel }

      # Proposition evaluation
      it { is_expected.to     be_display_proposition_evaluation }
      it { is_expected.not_to be_display_proposition_affectation }
      it { is_expected.to     be_display_proposition_nature }
      it { is_expected.to     be_display_proposition_categorie }
      it { is_expected.to     be_display_proposition_surface_reelle }
      it { is_expected.not_to be_display_other_proposition_surface }
      it { is_expected.not_to be_display_proposition_coefficient_localisation }
      it { is_expected.to     be_display_proposition_coefficient_entretien }
      it { is_expected.to     be_display_proposition_coefficient_situation }

      it { is_expected.not_to be_require_proposition_affectation }
      it { is_expected.to     be_require_proposition_nature }
      it { is_expected.to     be_require_proposition_categorie }
      it { is_expected.to     be_require_proposition_surface_reelle }
      it { is_expected.not_to be_require_proposition_coefficient_localisation }
      it { is_expected.to     be_require_proposition_coefficient_entretien }

      it { is_expected.to     be_expect_proposition_nature_habitation }
      it { is_expected.not_to be_expect_proposition_nature_professionnel }
      it { is_expected.not_to be_expect_proposition_nature_creation_local_habitation }
      it { is_expected.to     be_expect_proposition_categorie_habitation }
      it { is_expected.not_to be_expect_proposition_categorie_dependance }
      it { is_expected.not_to be_expect_proposition_categorie_professionnel }

      # Others
      it { is_expected.not_to be_display_situation_occupation }
      it { is_expected.not_to be_display_proposition_creation_local }
      it { is_expected.not_to be_display_proposition_occupation }
      it { is_expected.not_to be_display_proposition_exoneration }
      it { is_expected.not_to be_display_proposition_adresse }

      it { is_expected.not_to be_require_proposition_exoneration }
      it { is_expected.not_to be_require_proposition_adresse }

      context "with a 'consistance' anomaly and a proposition_nature set to dependance" do
        let(:report) do
          build_stubbed(:report,
            form_type: "evaluation_local_habitation",
            anomalies: %w[consistance],
            proposition_nature: "DA")
        end

        # Situation evaluation
        it { is_expected.to     be_display_situation_evaluation }
        it { is_expected.to     be_display_situation_date_mutation }
        it { is_expected.to     be_display_situation_affectation }
        it { is_expected.to     be_display_situation_nature }
        it { is_expected.to     be_display_situation_categorie }
        it { is_expected.to     be_display_situation_surface_reelle }
        it { is_expected.not_to be_display_other_situation_surface }
        it { is_expected.not_to be_display_situation_coefficient_localisation }
        it { is_expected.to     be_display_situation_coefficient_entretien }
        it { is_expected.to     be_display_situation_coefficient_situation }

        it { is_expected.to     be_require_situation_date_mutation }
        it { is_expected.to     be_require_situation_affectation }
        it { is_expected.to     be_require_situation_nature }
        it { is_expected.to     be_require_situation_categorie }
        it { is_expected.to     be_require_situation_surface_reelle }
        it { is_expected.not_to be_require_situation_coefficient_localisation }
        it { is_expected.to     be_require_situation_coefficient_entretien }

        it { is_expected.to     be_expect_situation_nature_habitation }
        it { is_expected.not_to be_expect_situation_nature_professionnel }
        it { is_expected.to     be_expect_situation_categorie_habitation }
        it { is_expected.not_to be_expect_situation_categorie_professionnel }

        # Proposition evaluation
        it { is_expected.to     be_display_proposition_evaluation }
        it { is_expected.not_to be_display_proposition_affectation }
        it { is_expected.to     be_display_proposition_nature }
        it { is_expected.to     be_display_proposition_categorie }
        it { is_expected.to     be_display_proposition_surface_reelle }
        it { is_expected.not_to be_display_other_proposition_surface }
        it { is_expected.not_to be_display_proposition_coefficient_localisation }
        it { is_expected.to     be_display_proposition_coefficient_entretien }
        it { is_expected.to     be_display_proposition_coefficient_situation }

        it { is_expected.not_to be_require_proposition_affectation }
        it { is_expected.to     be_require_proposition_nature }
        it { is_expected.to     be_require_proposition_nature_dependance }
        it { is_expected.to     be_require_proposition_categorie }
        it { is_expected.to     be_require_proposition_surface_reelle }
        it { is_expected.not_to be_require_proposition_coefficient_localisation }
        it { is_expected.to     be_require_proposition_coefficient_entretien }

        it { is_expected.to     be_expect_proposition_nature_habitation }
        it { is_expected.not_to be_expect_proposition_nature_professionnel }
        it { is_expected.not_to be_expect_proposition_nature_creation_local_habitation }
        it { is_expected.not_to be_expect_proposition_categorie_habitation }
        it { is_expected.to     be_expect_proposition_categorie_dependance }
        it { is_expected.not_to be_expect_proposition_categorie_professionnel }

        # Others
        it { is_expected.not_to be_display_situation_occupation }
        it { is_expected.not_to be_display_proposition_creation_local }
        it { is_expected.not_to be_display_proposition_occupation }
        it { is_expected.not_to be_display_proposition_exoneration }
        it { is_expected.not_to be_display_proposition_adresse }

        it { is_expected.not_to be_require_proposition_exoneration }
        it { is_expected.not_to be_require_proposition_adresse }
      end
    end

    context "with a 'correctif' anomaly" do
      let(:report) do
        build_stubbed(:report,
          form_type: "evaluation_local_habitation",
          anomalies: %w[correctif])
      end

      # Situation evaluation
      it { is_expected.to     be_display_situation_evaluation }
      it { is_expected.to     be_display_situation_date_mutation }
      it { is_expected.to     be_display_situation_affectation }
      it { is_expected.to     be_display_situation_nature }
      it { is_expected.to     be_display_situation_categorie }
      it { is_expected.to     be_display_situation_surface_reelle }
      it { is_expected.not_to be_display_other_situation_surface }
      it { is_expected.not_to be_display_situation_coefficient_localisation }
      it { is_expected.to     be_display_situation_coefficient_entretien }
      it { is_expected.to     be_display_situation_coefficient_situation }

      it { is_expected.to     be_require_situation_date_mutation }
      it { is_expected.to     be_require_situation_affectation }
      it { is_expected.to     be_require_situation_nature }
      it { is_expected.to     be_require_situation_categorie }
      it { is_expected.to     be_require_situation_surface_reelle }
      it { is_expected.not_to be_require_situation_coefficient_localisation }
      it { is_expected.to     be_require_situation_coefficient_entretien }

      it { is_expected.to     be_expect_situation_nature_habitation }
      it { is_expected.not_to be_expect_situation_nature_professionnel }
      it { is_expected.to     be_expect_situation_categorie_habitation }
      it { is_expected.not_to be_expect_situation_categorie_professionnel }

      # Proposition evaluation
      it { is_expected.to     be_display_proposition_evaluation }
      it { is_expected.not_to be_display_proposition_affectation }
      it { is_expected.not_to be_display_proposition_nature }
      it { is_expected.not_to be_display_proposition_categorie }
      it { is_expected.not_to be_display_proposition_surface_reelle }
      it { is_expected.not_to be_display_other_proposition_surface }
      it { is_expected.not_to be_display_proposition_coefficient_localisation }
      it { is_expected.to     be_display_proposition_coefficient_entretien }
      it { is_expected.to     be_display_proposition_coefficient_situation }

      it { is_expected.not_to be_require_proposition_affectation }
      it { is_expected.not_to be_require_proposition_nature }
      it { is_expected.not_to be_require_proposition_categorie }
      it { is_expected.not_to be_require_proposition_surface_reelle }
      it { is_expected.not_to be_require_proposition_coefficient_localisation }
      it { is_expected.to     be_require_proposition_coefficient_entretien }

      it { is_expected.not_to be_expect_proposition_nature_habitation }
      it { is_expected.not_to be_expect_proposition_nature_professionnel }
      it { is_expected.not_to be_expect_proposition_nature_creation_local_habitation }
      it { is_expected.not_to be_expect_proposition_categorie_habitation }
      it { is_expected.not_to be_expect_proposition_categorie_dependance }
      it { is_expected.not_to be_expect_proposition_categorie_professionnel }

      # Others
      it { is_expected.not_to be_display_situation_occupation }
      it { is_expected.not_to be_display_proposition_creation_local }
      it { is_expected.not_to be_display_proposition_occupation }
      it { is_expected.not_to be_display_proposition_exoneration }
      it { is_expected.not_to be_display_proposition_adresse }

      it { is_expected.not_to be_require_proposition_exoneration }
      it { is_expected.not_to be_require_proposition_adresse }
    end

    context "with an 'exoneration' anomaly" do
      let(:report) do
        build_stubbed(:report,
          form_type: "evaluation_local_habitation",
          anomalies: %w[exoneration])
      end

      # Situation evaluation
      it { is_expected.to     be_display_situation_evaluation }
      it { is_expected.to     be_display_situation_date_mutation }
      it { is_expected.to     be_display_situation_affectation }
      it { is_expected.to     be_display_situation_nature }
      it { is_expected.to     be_display_situation_categorie }
      it { is_expected.to     be_display_situation_surface_reelle }
      it { is_expected.not_to be_display_other_situation_surface }
      it { is_expected.not_to be_display_situation_coefficient_localisation }
      it { is_expected.to     be_display_situation_coefficient_entretien }
      it { is_expected.to     be_display_situation_coefficient_situation }

      it { is_expected.to     be_require_situation_date_mutation }
      it { is_expected.to     be_require_situation_affectation }
      it { is_expected.to     be_require_situation_nature }
      it { is_expected.to     be_require_situation_categorie }
      it { is_expected.to     be_require_situation_surface_reelle }
      it { is_expected.not_to be_require_situation_coefficient_localisation }
      it { is_expected.to     be_require_situation_coefficient_entretien }

      it { is_expected.to     be_expect_situation_nature_habitation }
      it { is_expected.not_to be_expect_situation_nature_professionnel }
      it { is_expected.to     be_expect_situation_categorie_habitation }
      it { is_expected.not_to be_expect_situation_categorie_professionnel }

      # Proposition evaluation
      it { is_expected.not_to be_display_proposition_evaluation }
      it { is_expected.not_to be_display_proposition_affectation }
      it { is_expected.not_to be_display_proposition_nature }
      it { is_expected.not_to be_display_proposition_categorie }
      it { is_expected.not_to be_display_proposition_surface_reelle }
      it { is_expected.not_to be_display_other_proposition_surface }
      it { is_expected.not_to be_display_proposition_coefficient_localisation }
      it { is_expected.not_to be_display_proposition_coefficient_entretien }
      it { is_expected.not_to be_display_proposition_coefficient_situation }

      it { is_expected.not_to be_require_proposition_affectation }
      it { is_expected.not_to be_require_proposition_nature }
      it { is_expected.not_to be_require_proposition_categorie }
      it { is_expected.not_to be_require_proposition_surface_reelle }
      it { is_expected.not_to be_require_proposition_coefficient_localisation }
      it { is_expected.not_to be_require_proposition_coefficient_entretien }

      it { is_expected.not_to be_expect_proposition_nature_habitation }
      it { is_expected.not_to be_expect_proposition_nature_professionnel }
      it { is_expected.not_to be_expect_proposition_nature_creation_local_habitation }
      it { is_expected.not_to be_expect_proposition_categorie_habitation }
      it { is_expected.not_to be_expect_proposition_categorie_dependance }
      it { is_expected.not_to be_expect_proposition_categorie_professionnel }

      # Others
      it { is_expected.not_to be_display_situation_occupation }
      it { is_expected.not_to be_display_proposition_creation_local }
      it { is_expected.not_to be_display_proposition_occupation }
      it { is_expected.to     be_display_proposition_exoneration }
      it { is_expected.not_to be_display_proposition_adresse }

      it { is_expected.to     be_require_proposition_exoneration }
      it { is_expected.not_to be_require_proposition_adresse }
    end

    context "with an 'adresse' anomaly" do
      let(:report) do
        build_stubbed(:report,
          form_type: "evaluation_local_habitation",
          anomalies: %w[adresse])
      end

      # Address
      it { is_expected.to be_display_proposition_adresse }
      it { is_expected.to be_require_proposition_adresse }

      # Others
      it { is_expected.not_to be_display_situation_evaluation }
      it { is_expected.not_to be_display_situation_occupation }
      it { is_expected.not_to be_display_proposition_evaluation }
      it { is_expected.not_to be_display_proposition_creation_local }
      it { is_expected.not_to be_display_proposition_occupation }
      it { is_expected.not_to be_display_proposition_exoneration }

      it { is_expected.not_to be_require_situation_date_mutation }
      it { is_expected.not_to be_require_situation_affectation }
      it { is_expected.not_to be_require_situation_nature }
      it { is_expected.not_to be_require_situation_categorie }
      it { is_expected.not_to be_require_situation_surface_reelle }
      it { is_expected.not_to be_require_situation_coefficient_localisation }
      it { is_expected.not_to be_require_situation_coefficient_entretien }

      it { is_expected.not_to be_require_proposition_affectation }
      it { is_expected.not_to be_require_proposition_nature }
      it { is_expected.not_to be_require_proposition_categorie }
      it { is_expected.not_to be_require_proposition_surface_reelle }
      it { is_expected.not_to be_require_proposition_coefficient_localisation }
      it { is_expected.not_to be_require_proposition_coefficient_entretien }

      it { is_expected.not_to be_require_proposition_exoneration }
    end
  end

  context "with an evaluation_local_professionnel" do
    context "without any anomalies" do
      let(:report) do
        build_stubbed(:report, form_type: "evaluation_local_professionnel")
      end

      # Situation MAJIC
      it { is_expected.to be_display_situation_majic }
      it { is_expected.to be_display_situation_annee_majic }
      it { is_expected.to be_display_situation_invariant }
      it { is_expected.to be_display_situation_parcelle }
      it { is_expected.to be_display_situation_adresse }
      it { is_expected.to be_display_situation_porte }
      it { is_expected.to be_display_situation_proprietaire }

      it { is_expected.to be_require_situation_annee_majic }
      it { is_expected.to be_require_situation_invariant }
      it { is_expected.to be_require_situation_parcelle }
      it { is_expected.to be_require_situation_adresse }
      it { is_expected.to be_require_situation_porte }
      it { is_expected.to be_require_situation_proprietaire }

      # Others
      it { is_expected.not_to be_display_situation_evaluation }
      it { is_expected.not_to be_display_situation_occupation }
      it { is_expected.not_to be_display_proposition_creation_local }
      it { is_expected.not_to be_display_proposition_occupation }
      it { is_expected.not_to be_display_proposition_exoneration }
      it { is_expected.not_to be_display_proposition_adresse }
    end

    context "with an 'affectaction' anomaly" do
      let(:report) do
        build_stubbed(:report,
          form_type: "evaluation_local_professionnel",
          anomalies: %w[affectation])
      end

      # Situation evaluation
      it { is_expected.to     be_display_situation_evaluation }
      it { is_expected.to     be_display_situation_date_mutation }
      it { is_expected.to     be_display_situation_affectation }
      it { is_expected.to     be_display_situation_nature }
      it { is_expected.to     be_display_situation_categorie }
      it { is_expected.to     be_display_situation_surface_reelle }
      it { is_expected.to     be_display_other_situation_surface }
      it { is_expected.to     be_display_situation_coefficient_localisation }
      it { is_expected.not_to be_display_situation_coefficient_entretien }
      it { is_expected.not_to be_display_situation_coefficient_situation }

      it { is_expected.to     be_require_situation_date_mutation }
      it { is_expected.to     be_require_situation_affectation }
      it { is_expected.to     be_require_situation_nature }
      it { is_expected.to     be_require_situation_categorie }
      it { is_expected.to     be_require_situation_surface_reelle }
      it { is_expected.to     be_require_situation_coefficient_localisation }
      it { is_expected.not_to be_require_situation_coefficient_entretien }

      it { is_expected.not_to be_expect_situation_nature_habitation }
      it { is_expected.to     be_expect_situation_nature_professionnel }
      it { is_expected.not_to be_expect_situation_categorie_habitation }
      it { is_expected.not_to be_expect_situation_categorie_dependance }
      it { is_expected.to     be_expect_situation_categorie_professionnel }

      # Proposition evaluation
      it { is_expected.to     be_display_proposition_evaluation }
      it { is_expected.to     be_display_proposition_affectation }
      it { is_expected.to     be_display_proposition_nature }
      it { is_expected.not_to be_display_proposition_nature_dependance }
      it { is_expected.to     be_display_proposition_categorie }
      it { is_expected.to     be_display_proposition_surface_reelle }
      it { is_expected.not_to be_display_other_proposition_surface }
      it { is_expected.not_to be_display_proposition_coefficient_localisation }
      it { is_expected.not_to be_display_proposition_coefficient_entretien }
      it { is_expected.not_to be_display_proposition_coefficient_situation }

      it { is_expected.to     be_require_proposition_affectation }
      it { is_expected.to     be_require_proposition_nature }
      it { is_expected.not_to be_require_proposition_nature_dependance }
      it { is_expected.to     be_require_proposition_categorie }
      it { is_expected.to     be_require_proposition_surface_reelle }
      it { is_expected.not_to be_require_proposition_coefficient_localisation }
      it { is_expected.not_to be_require_proposition_coefficient_entretien }

      it { is_expected.not_to be_expect_proposition_nature_habitation }
      it { is_expected.not_to be_expect_proposition_nature_professionnel }
      it { is_expected.not_to be_expect_proposition_nature_creation_local_habitation }
      it { is_expected.not_to be_expect_proposition_categorie_habitation }
      it { is_expected.not_to be_expect_proposition_categorie_dependance }
      it { is_expected.not_to be_expect_proposition_categorie_professionnel }

      # Others
      it { is_expected.not_to be_display_situation_occupation }
      it { is_expected.not_to be_display_proposition_creation_local }
      it { is_expected.not_to be_display_proposition_occupation }
      it { is_expected.not_to be_display_proposition_exoneration }
      it { is_expected.not_to be_display_proposition_adresse }

      it { is_expected.not_to be_require_proposition_exoneration }
      it { is_expected.not_to be_require_proposition_adresse }

      context "when setting proposition_affectation to habitation" do
        let(:report) do
          build_stubbed(:report,
            form_type: "evaluation_local_professionnel",
            anomalies: %w[affectation],
            proposition_affectation: "H")
        end

        # Proposition evaluation
        it { is_expected.to     be_display_proposition_evaluation }
        it { is_expected.to     be_display_proposition_affectation }
        it { is_expected.to     be_display_proposition_nature }
        it { is_expected.not_to be_display_proposition_nature_dependance }
        it { is_expected.to     be_display_proposition_categorie }
        it { is_expected.to     be_display_proposition_surface_reelle }
        it { is_expected.not_to be_display_other_proposition_surface }
        it { is_expected.not_to be_display_proposition_coefficient_localisation }
        it { is_expected.to     be_display_proposition_coefficient_entretien }
        it { is_expected.to     be_display_proposition_coefficient_situation }

        it { is_expected.to     be_require_proposition_affectation }
        it { is_expected.to     be_require_proposition_nature }
        it { is_expected.not_to be_require_proposition_nature_dependance }
        it { is_expected.to     be_require_proposition_categorie }
        it { is_expected.to     be_require_proposition_surface_reelle }
        it { is_expected.not_to be_require_proposition_coefficient_localisation }
        it { is_expected.to     be_require_proposition_coefficient_entretien }

        it { is_expected.to     be_expect_proposition_nature_habitation }
        it { is_expected.not_to be_expect_proposition_nature_professionnel }
        it { is_expected.not_to be_expect_proposition_nature_creation_local_habitation }
        it { is_expected.to     be_expect_proposition_categorie_habitation }
        it { is_expected.not_to be_expect_proposition_categorie_dependance }
        it { is_expected.not_to be_expect_proposition_categorie_professionnel }

        # Others
        it { is_expected.not_to be_display_situation_occupation }
        it { is_expected.not_to be_display_proposition_creation_local }
        it { is_expected.not_to be_display_proposition_occupation }
        it { is_expected.not_to be_display_proposition_exoneration }
        it { is_expected.not_to be_display_proposition_adresse }

        it { is_expected.not_to be_require_proposition_exoneration }
        it { is_expected.not_to be_require_proposition_adresse }
      end

      context "when setting proposition_affectation to habitation and proposition_nature to dependance" do
        let(:report) do
          build_stubbed(:report,
            form_type: "evaluation_local_professionnel",
            anomalies: %w[affectation],
            proposition_affectation: "H",
            proposition_nature: "DA")
        end

        # Proposition evaluation
        it { is_expected.to     be_display_proposition_evaluation }
        it { is_expected.to     be_display_proposition_affectation }
        it { is_expected.to     be_display_proposition_nature }
        it { is_expected.to     be_display_proposition_nature_dependance }
        it { is_expected.to     be_display_proposition_categorie }
        it { is_expected.to     be_display_proposition_surface_reelle }
        it { is_expected.not_to be_display_other_proposition_surface }
        it { is_expected.not_to be_display_proposition_coefficient_localisation }
        it { is_expected.to     be_display_proposition_coefficient_entretien }
        it { is_expected.to     be_display_proposition_coefficient_situation }

        it { is_expected.to     be_require_proposition_affectation }
        it { is_expected.to     be_require_proposition_nature }
        it { is_expected.to     be_require_proposition_nature_dependance }
        it { is_expected.to     be_require_proposition_categorie }
        it { is_expected.to     be_require_proposition_surface_reelle }
        it { is_expected.not_to be_require_proposition_coefficient_localisation }
        it { is_expected.to     be_require_proposition_coefficient_entretien }

        it { is_expected.to     be_expect_proposition_nature_habitation }
        it { is_expected.not_to be_expect_proposition_nature_professionnel }
        it { is_expected.not_to be_expect_proposition_nature_creation_local_habitation }
        it { is_expected.not_to be_expect_proposition_categorie_habitation }
        it { is_expected.to     be_expect_proposition_categorie_dependance }
        it { is_expected.not_to be_expect_proposition_categorie_professionnel }

        # Others
        it { is_expected.not_to be_display_situation_occupation }
        it { is_expected.not_to be_display_proposition_creation_local }
        it { is_expected.not_to be_display_proposition_occupation }
        it { is_expected.not_to be_display_proposition_exoneration }
        it { is_expected.not_to be_display_proposition_adresse }

        it { is_expected.not_to be_require_proposition_exoneration }
        it { is_expected.not_to be_require_proposition_adresse }
      end

      context "when setting proposition_affectation to professionnal" do
        let(:report) do
          build_stubbed(:report,
            form_type: "evaluation_local_professionnel",
            anomalies: %w[affectation],
            proposition_affectation: "C")
        end

        # Proposition evaluation
        it { is_expected.to     be_display_proposition_evaluation }
        it { is_expected.to     be_display_proposition_affectation }
        it { is_expected.to     be_display_proposition_nature }
        it { is_expected.not_to be_display_proposition_nature_dependance }
        it { is_expected.to     be_display_proposition_categorie }
        it { is_expected.to     be_display_proposition_surface_reelle }
        it { is_expected.to     be_display_other_proposition_surface }
        it { is_expected.to     be_display_proposition_coefficient_localisation }
        it { is_expected.not_to be_display_proposition_coefficient_entretien }
        it { is_expected.not_to be_display_proposition_coefficient_situation }

        it { is_expected.to     be_require_proposition_affectation }
        it { is_expected.to     be_require_proposition_nature }
        it { is_expected.not_to be_require_proposition_nature_dependance }
        it { is_expected.to     be_require_proposition_categorie }
        it { is_expected.to     be_require_proposition_surface_reelle }
        it { is_expected.to     be_require_proposition_coefficient_localisation }
        it { is_expected.not_to be_require_proposition_coefficient_entretien }

        it { is_expected.not_to be_expect_proposition_nature_habitation }
        it { is_expected.to     be_expect_proposition_nature_professionnel }
        it { is_expected.not_to be_expect_proposition_nature_creation_local_habitation }
        it { is_expected.not_to be_expect_proposition_categorie_habitation }
        it { is_expected.not_to be_expect_proposition_categorie_dependance }
        it { is_expected.to     be_expect_proposition_categorie_professionnel }

        # Others
        it { is_expected.not_to be_display_situation_occupation }
        it { is_expected.not_to be_display_proposition_creation_local }
        it { is_expected.not_to be_display_proposition_occupation }
        it { is_expected.not_to be_display_proposition_exoneration }
        it { is_expected.not_to be_display_proposition_adresse }

        it { is_expected.not_to be_require_proposition_exoneration }
        it { is_expected.not_to be_require_proposition_adresse }
      end

      context "when setting proposition_nature set to industrial" do
        let(:report) do
          build_stubbed(:report,
            form_type: "evaluation_local_professionnel",
            anomalies: %w[affectation],
            proposition_affectation: "B",
            proposition_nature:      "U")
        end

        # Proposition evaluation
        it { is_expected.to     be_display_proposition_evaluation }
        it { is_expected.to     be_display_proposition_affectation }
        it { is_expected.to     be_display_proposition_nature }
        it { is_expected.not_to be_display_proposition_nature_dependance }
        it { is_expected.to     be_display_proposition_categorie }
        it { is_expected.to     be_display_proposition_surface_reelle }
        it { is_expected.to     be_display_other_proposition_surface }
        it { is_expected.to     be_display_proposition_coefficient_localisation }
        it { is_expected.not_to be_display_proposition_coefficient_entretien }
        it { is_expected.not_to be_display_proposition_coefficient_situation }

        it { is_expected.to     be_require_proposition_affectation }
        it { is_expected.to     be_require_proposition_nature }
        it { is_expected.not_to be_require_proposition_nature_dependance }
        it { is_expected.not_to be_require_proposition_categorie }
        it { is_expected.not_to be_require_proposition_surface_reelle }
        it { is_expected.not_to be_require_proposition_coefficient_localisation }
        it { is_expected.not_to be_require_proposition_coefficient_entretien }

        it { is_expected.not_to be_expect_proposition_nature_habitation }
        it { is_expected.to     be_expect_proposition_nature_professionnel }
        it { is_expected.not_to be_expect_proposition_nature_creation_local_habitation }
        it { is_expected.not_to be_expect_proposition_categorie_habitation }
        it { is_expected.not_to be_expect_proposition_categorie_dependance }
        it { is_expected.to     be_expect_proposition_categorie_professionnel }

        # Others
        it { is_expected.not_to be_display_situation_occupation }
        it { is_expected.not_to be_display_proposition_creation_local }
        it { is_expected.not_to be_display_proposition_occupation }
        it { is_expected.not_to be_display_proposition_exoneration }
        it { is_expected.not_to be_display_proposition_adresse }

        it { is_expected.not_to be_require_proposition_exoneration }
        it { is_expected.not_to be_require_proposition_adresse }
      end
    end

    context "without a 'consistance' anomaly" do
      let(:report) do
        build_stubbed(:report,
          form_type: "evaluation_local_professionnel",
          anomalies: %w[consistance])
      end

      # Situation evaluation
      it { is_expected.to     be_display_situation_evaluation }
      it { is_expected.to     be_display_situation_date_mutation }
      it { is_expected.to     be_display_situation_affectation }
      it { is_expected.to     be_display_situation_nature }
      it { is_expected.to     be_display_situation_categorie }
      it { is_expected.to     be_display_situation_surface_reelle }
      it { is_expected.to     be_display_other_situation_surface }
      it { is_expected.to     be_display_situation_coefficient_localisation }
      it { is_expected.not_to be_display_situation_coefficient_entretien }
      it { is_expected.not_to be_display_situation_coefficient_situation }

      it { is_expected.to     be_require_situation_date_mutation }
      it { is_expected.to     be_require_situation_affectation }
      it { is_expected.to     be_require_situation_nature }
      it { is_expected.to     be_require_situation_categorie }
      it { is_expected.to     be_require_situation_surface_reelle }
      it { is_expected.to     be_require_situation_coefficient_localisation }
      it { is_expected.not_to be_require_situation_coefficient_entretien }

      it { is_expected.not_to be_expect_situation_nature_habitation }
      it { is_expected.to     be_expect_situation_nature_professionnel }
      it { is_expected.not_to be_expect_situation_categorie_habitation }
      it { is_expected.to     be_expect_situation_categorie_professionnel }

      # Proposition evaluation
      it { is_expected.to     be_display_proposition_evaluation }
      it { is_expected.not_to be_display_proposition_affectation }
      it { is_expected.not_to be_display_proposition_nature }
      it { is_expected.not_to be_display_proposition_nature_dependance }
      it { is_expected.to     be_display_proposition_categorie }
      it { is_expected.to     be_display_proposition_surface_reelle }
      it { is_expected.to     be_display_other_proposition_surface }
      it { is_expected.to     be_display_proposition_coefficient_localisation }
      it { is_expected.not_to be_display_proposition_coefficient_entretien }
      it { is_expected.not_to be_display_proposition_coefficient_situation }

      it { is_expected.not_to be_require_proposition_affectation }
      it { is_expected.not_to be_require_proposition_nature }
      it { is_expected.not_to be_require_proposition_nature_dependance }
      it { is_expected.to     be_require_proposition_categorie }
      it { is_expected.to     be_require_proposition_surface_reelle }
      it { is_expected.to     be_require_proposition_coefficient_localisation }
      it { is_expected.not_to be_require_proposition_coefficient_entretien }

      it { is_expected.not_to be_expect_proposition_nature_habitation }
      it { is_expected.not_to be_expect_proposition_nature_professionnel }
      it { is_expected.not_to be_expect_proposition_nature_creation_local_habitation }
      it { is_expected.not_to be_expect_proposition_categorie_habitation }
      it { is_expected.not_to be_expect_proposition_categorie_dependance }
      it { is_expected.to     be_expect_proposition_categorie_professionnel }

      # Others
      it { is_expected.not_to be_display_situation_occupation }
      it { is_expected.not_to be_display_proposition_creation_local }
      it { is_expected.not_to be_display_proposition_occupation }
      it { is_expected.not_to be_display_proposition_exoneration }
      it { is_expected.not_to be_display_proposition_adresse }

      it { is_expected.not_to be_require_proposition_exoneration }
      it { is_expected.not_to be_require_proposition_adresse }
    end

    context "with an 'exoneration' anomaly" do
      let(:report) do
        build_stubbed(:report,
          form_type: "evaluation_local_professionnel",
          anomalies: %w[exoneration])
      end

      # Situation evaluation
      it { is_expected.to     be_display_situation_evaluation }
      it { is_expected.to     be_display_situation_date_mutation }
      it { is_expected.to     be_display_situation_affectation }
      it { is_expected.to     be_display_situation_nature }
      it { is_expected.to     be_display_situation_categorie }
      it { is_expected.to     be_display_situation_surface_reelle }
      it { is_expected.to     be_display_other_situation_surface }
      it { is_expected.to     be_display_situation_coefficient_localisation }
      it { is_expected.not_to be_display_situation_coefficient_entretien }
      it { is_expected.not_to be_display_situation_coefficient_situation }

      it { is_expected.to     be_require_situation_date_mutation }
      it { is_expected.to     be_require_situation_affectation }
      it { is_expected.to     be_require_situation_nature }
      it { is_expected.to     be_require_situation_categorie }
      it { is_expected.to     be_require_situation_surface_reelle }
      it { is_expected.to     be_require_situation_coefficient_localisation }
      it { is_expected.not_to be_require_situation_coefficient_entretien }

      it { is_expected.not_to be_expect_situation_nature_habitation }
      it { is_expected.to     be_expect_situation_nature_professionnel }
      it { is_expected.not_to be_expect_situation_categorie_habitation }
      it { is_expected.to     be_expect_situation_categorie_professionnel }

      # Proposition evaluation
      it { is_expected.not_to be_display_proposition_evaluation }
      it { is_expected.not_to be_display_proposition_affectation }
      it { is_expected.not_to be_display_proposition_nature }
      it { is_expected.not_to be_display_proposition_nature_dependance }
      it { is_expected.not_to be_display_proposition_categorie }
      it { is_expected.not_to be_display_proposition_surface_reelle }
      it { is_expected.not_to be_display_other_proposition_surface }
      it { is_expected.not_to be_display_proposition_coefficient_localisation }
      it { is_expected.not_to be_display_proposition_coefficient_entretien }
      it { is_expected.not_to be_display_proposition_coefficient_situation }

      it { is_expected.not_to be_require_proposition_affectation }
      it { is_expected.not_to be_require_proposition_nature }
      it { is_expected.not_to be_require_proposition_categorie }
      it { is_expected.not_to be_require_proposition_nature_dependance }
      it { is_expected.not_to be_require_proposition_surface_reelle }
      it { is_expected.not_to be_require_proposition_coefficient_localisation }
      it { is_expected.not_to be_require_proposition_coefficient_entretien }

      # Others
      it { is_expected.not_to be_display_situation_occupation }
      it { is_expected.not_to be_display_proposition_creation_local }
      it { is_expected.not_to be_display_proposition_occupation }
      it { is_expected.to     be_display_proposition_exoneration }
      it { is_expected.not_to be_display_proposition_adresse }

      it { is_expected.to     be_require_proposition_exoneration }
      it { is_expected.not_to be_require_proposition_adresse }
    end

    context "with an 'adresse' anomaly" do
      let(:report) do
        build_stubbed(:report,
          form_type: "evaluation_local_professionnel",
          anomalies: %w[adresse])
      end

      # Address
      it { is_expected.to be_display_proposition_adresse }
      it { is_expected.to be_require_proposition_adresse }

      # Others
      it { is_expected.not_to be_display_situation_evaluation }
      it { is_expected.not_to be_display_situation_occupation }
      it { is_expected.not_to be_display_proposition_evaluation }
      it { is_expected.not_to be_display_proposition_creation_local }
      it { is_expected.not_to be_display_proposition_occupation }
      it { is_expected.not_to be_display_proposition_exoneration }

      it { is_expected.not_to be_require_situation_date_mutation }
      it { is_expected.not_to be_require_situation_affectation }
      it { is_expected.not_to be_require_situation_nature }
      it { is_expected.not_to be_require_proposition_nature_dependance }
      it { is_expected.not_to be_require_situation_categorie }
      it { is_expected.not_to be_require_situation_surface_reelle }
      it { is_expected.not_to be_require_situation_coefficient_localisation }
      it { is_expected.not_to be_require_situation_coefficient_entretien }

      it { is_expected.not_to be_require_proposition_affectation }
      it { is_expected.not_to be_require_proposition_nature }
      it { is_expected.not_to be_require_proposition_categorie }
      it { is_expected.not_to be_require_proposition_surface_reelle }
      it { is_expected.not_to be_require_proposition_coefficient_localisation }
      it { is_expected.not_to be_require_proposition_coefficient_entretien }

      it { is_expected.not_to be_require_proposition_exoneration }
    end
  end

  context "with a creation_local_habitation" do
    context "without any anomalies" do
      let(:report) do
        build_stubbed(:report, form_type: "creation_local_habitation")
      end

      # Situation MAJIC
      it { is_expected.not_to be_display_situation_majic }
      it { is_expected.not_to be_display_situation_annee_majic }
      it { is_expected.not_to be_display_situation_invariant }
      it { is_expected.to     be_display_situation_parcelle }
      it { is_expected.to     be_display_situation_adresse }
      it { is_expected.not_to be_display_situation_porte }
      it { is_expected.to     be_display_situation_proprietaire }

      it { is_expected.not_to be_require_situation_annee_majic }
      it { is_expected.not_to be_require_situation_invariant }
      it { is_expected.to     be_require_situation_parcelle }
      it { is_expected.to     be_require_situation_adresse }
      it { is_expected.not_to be_require_situation_porte }
      it { is_expected.to     be_require_situation_proprietaire }

      # Proposition creation
      it { is_expected.to     be_display_proposition_creation_local }
      it { is_expected.to     be_display_proposition_nature }
      it { is_expected.not_to be_display_proposition_nature_dependance }
      it { is_expected.to     be_display_proposition_categorie }
      it { is_expected.to     be_display_proposition_surface_reelle }
      it { is_expected.to     be_display_proposition_date_achevement }
      it { is_expected.not_to be_display_proposition_numero_permis }
      it { is_expected.not_to be_display_proposition_nature_travaux }

      it { is_expected.to     be_require_proposition_nature }
      it { is_expected.not_to be_require_proposition_nature_dependance }
      it { is_expected.to     be_require_proposition_categorie }
      it { is_expected.to     be_require_proposition_surface_reelle }
      it { is_expected.to     be_require_proposition_date_achevement }
      it { is_expected.not_to be_require_proposition_numero_permis }
      it { is_expected.not_to be_require_proposition_nature_travaux }

      it { is_expected.not_to be_expect_proposition_nature_habitation }
      it { is_expected.not_to be_expect_proposition_nature_professionnel }
      it { is_expected.to     be_expect_proposition_nature_creation_local_habitation }
      it { is_expected.to     be_expect_proposition_categorie_habitation }
      it { is_expected.not_to be_expect_proposition_categorie_dependance }
      it { is_expected.not_to be_expect_proposition_categorie_professionnel }

      # Others
      it { is_expected.not_to be_display_situation_evaluation }
      it { is_expected.not_to be_display_situation_occupation }
      it { is_expected.not_to be_display_proposition_evaluation }
      it { is_expected.not_to be_display_proposition_occupation }
      it { is_expected.not_to be_display_proposition_exoneration }
      it { is_expected.not_to be_display_proposition_adresse }
    end

    context "without an 'omission_batie' anomalies" do
      let(:report) do
        build_stubbed(:report,
          form_type: "creation_local_habitation",
          anomalies: %w[omission_batie])
      end

      # Situation MAJIC
      it { is_expected.not_to be_display_situation_majic }
      it { is_expected.not_to be_display_situation_annee_majic }
      it { is_expected.not_to be_display_situation_invariant }
      it { is_expected.to     be_display_situation_parcelle }
      it { is_expected.to     be_display_situation_adresse }
      it { is_expected.not_to be_display_situation_porte }
      it { is_expected.to     be_display_situation_proprietaire }

      it { is_expected.not_to be_require_situation_annee_majic }
      it { is_expected.not_to be_require_situation_invariant }
      it { is_expected.to     be_require_situation_parcelle }
      it { is_expected.to     be_require_situation_adresse }
      it { is_expected.not_to be_require_situation_porte }
      it { is_expected.to     be_require_situation_proprietaire }

      # Proposition creation
      it { is_expected.to     be_display_proposition_creation_local }
      it { is_expected.to     be_display_proposition_nature }
      it { is_expected.not_to be_display_proposition_nature_dependance }
      it { is_expected.to     be_display_proposition_categorie }
      it { is_expected.to     be_display_proposition_surface_reelle }
      it { is_expected.to     be_display_proposition_date_achevement }
      it { is_expected.not_to be_display_proposition_numero_permis }
      it { is_expected.not_to be_display_proposition_nature_travaux }

      it { is_expected.to     be_require_proposition_nature }
      it { is_expected.not_to be_require_proposition_nature_dependance }
      it { is_expected.to     be_require_proposition_categorie }
      it { is_expected.to     be_require_proposition_surface_reelle }
      it { is_expected.to     be_require_proposition_date_achevement }
      it { is_expected.not_to be_require_proposition_numero_permis }
      it { is_expected.not_to be_require_proposition_nature_travaux }

      it { is_expected.not_to be_expect_proposition_nature_habitation }
      it { is_expected.not_to be_expect_proposition_nature_professionnel }
      it { is_expected.to     be_expect_proposition_nature_creation_local_habitation }
      it { is_expected.to     be_expect_proposition_categorie_habitation }
      it { is_expected.not_to be_expect_proposition_categorie_dependance }
      it { is_expected.not_to be_expect_proposition_categorie_professionnel }

      # Others
      it { is_expected.not_to be_display_situation_evaluation }
      it { is_expected.not_to be_display_situation_occupation }
      it { is_expected.not_to be_display_proposition_evaluation }
      it { is_expected.not_to be_display_proposition_occupation }
      it { is_expected.not_to be_display_proposition_exoneration }
      it { is_expected.not_to be_display_proposition_adresse }

      context "when setting proposition_nature to a dependency" do
        let(:report) do
          build_stubbed(:report,
            form_type: "creation_local_habitation",
            anomalies: %w[construction_neuve],
            proposition_nature: "DA")
        end

        it { is_expected.to be_display_proposition_nature_dependance }
        it { is_expected.to be_require_proposition_nature_dependance }

        it { is_expected.not_to be_expect_proposition_nature_habitation }
        it { is_expected.not_to be_expect_proposition_nature_professionnel }
        it { is_expected.to     be_expect_proposition_nature_creation_local_habitation }
        it { is_expected.not_to be_expect_proposition_categorie_habitation }
        it { is_expected.to     be_expect_proposition_categorie_dependance }
        it { is_expected.not_to be_expect_proposition_categorie_professionnel }
      end
    end

    context "without an 'construction_neuve' anomalies" do
      let(:report) do
        build_stubbed(:report,
          form_type: "creation_local_habitation",
          anomalies: %w[construction_neuve])
      end

      # Situation MAJIC
      it { is_expected.not_to be_display_situation_majic }
      it { is_expected.not_to be_display_situation_annee_majic }
      it { is_expected.not_to be_display_situation_invariant }
      it { is_expected.to     be_display_situation_parcelle }
      it { is_expected.to     be_display_situation_adresse }
      it { is_expected.not_to be_display_situation_porte }
      it { is_expected.to     be_display_situation_proprietaire }

      it { is_expected.not_to be_require_situation_annee_majic }
      it { is_expected.not_to be_require_situation_invariant }
      it { is_expected.to     be_require_situation_parcelle }
      it { is_expected.to     be_require_situation_adresse }
      it { is_expected.not_to be_require_situation_porte }
      it { is_expected.to     be_require_situation_proprietaire }

      # Proposition creation
      it { is_expected.to     be_display_proposition_creation_local }
      it { is_expected.to     be_display_proposition_nature }
      it { is_expected.not_to be_display_proposition_nature_dependance }
      it { is_expected.to     be_display_proposition_categorie }
      it { is_expected.to     be_display_proposition_surface_reelle }
      it { is_expected.to     be_display_proposition_date_achevement }
      it { is_expected.to     be_display_proposition_numero_permis }
      it { is_expected.to     be_display_proposition_nature_travaux }

      it { is_expected.to     be_require_proposition_nature }
      it { is_expected.not_to be_require_proposition_nature_dependance }
      it { is_expected.to     be_require_proposition_categorie }
      it { is_expected.to     be_require_proposition_surface_reelle }
      it { is_expected.to     be_require_proposition_date_achevement }
      it { is_expected.to     be_require_proposition_numero_permis }
      it { is_expected.to     be_require_proposition_nature_travaux }

      it { is_expected.not_to be_expect_proposition_nature_habitation }
      it { is_expected.not_to be_expect_proposition_nature_professionnel }
      it { is_expected.to     be_expect_proposition_nature_creation_local_habitation }
      it { is_expected.to     be_expect_proposition_categorie_habitation }
      it { is_expected.not_to be_expect_proposition_categorie_dependance }
      it { is_expected.not_to be_expect_proposition_categorie_professionnel }

      # Others
      it { is_expected.not_to be_display_situation_evaluation }
      it { is_expected.not_to be_display_situation_occupation }
      it { is_expected.not_to be_display_proposition_evaluation }
      it { is_expected.not_to be_display_proposition_occupation }
      it { is_expected.not_to be_display_proposition_exoneration }
      it { is_expected.not_to be_display_proposition_adresse }

      context "when setting proposition_nature to a dependency" do
        let(:report) do
          build_stubbed(:report,
            form_type: "creation_local_habitation",
            anomalies: %w[construction_neuve],
            proposition_nature: "DA")
        end

        it { is_expected.to be_display_proposition_nature_dependance }
        it { is_expected.to be_require_proposition_nature_dependance }

        it { is_expected.not_to be_expect_proposition_nature_habitation }
        it { is_expected.not_to be_expect_proposition_nature_professionnel }
        it { is_expected.to     be_expect_proposition_nature_creation_local_habitation }
        it { is_expected.not_to be_expect_proposition_categorie_habitation }
        it { is_expected.to     be_expect_proposition_categorie_dependance }
        it { is_expected.not_to be_expect_proposition_categorie_professionnel }
      end
    end
  end

  context "with a creation_local_professionnel" do
    context "without any anomalies" do
      let(:report) do
        build_stubbed(:report, form_type: "creation_local_professionnel")
      end

      # Situation MAJIC
      it { is_expected.not_to be_display_situation_majic }
      it { is_expected.not_to be_display_situation_annee_majic }
      it { is_expected.not_to be_display_situation_invariant }
      it { is_expected.to     be_display_situation_parcelle }
      it { is_expected.to     be_display_situation_adresse }
      it { is_expected.not_to be_display_situation_porte }
      it { is_expected.to     be_display_situation_proprietaire }

      it { is_expected.not_to be_require_situation_annee_majic }
      it { is_expected.not_to be_require_situation_invariant }
      it { is_expected.to     be_require_situation_parcelle }
      it { is_expected.to     be_require_situation_adresse }
      it { is_expected.not_to be_require_situation_porte }
      it { is_expected.to     be_require_situation_proprietaire }

      # Proposition creation
      it { is_expected.to     be_display_proposition_creation_local }
      it { is_expected.to     be_display_proposition_nature }
      it { is_expected.not_to be_display_proposition_nature_dependance }
      it { is_expected.to     be_display_proposition_categorie }
      it { is_expected.to     be_display_proposition_surface_reelle }
      it { is_expected.to     be_display_proposition_date_achevement }
      it { is_expected.not_to be_display_proposition_numero_permis }
      it { is_expected.not_to be_display_proposition_nature_travaux }

      it { is_expected.to     be_require_proposition_nature }
      it { is_expected.not_to be_require_proposition_nature_dependance }
      it { is_expected.to     be_require_proposition_categorie }
      it { is_expected.to     be_require_proposition_surface_reelle }
      it { is_expected.to     be_require_proposition_date_achevement }
      it { is_expected.not_to be_require_proposition_numero_permis }
      it { is_expected.not_to be_require_proposition_nature_travaux }

      it { is_expected.not_to be_expect_proposition_nature_habitation }
      it { is_expected.to     be_expect_proposition_nature_professionnel }
      it { is_expected.not_to be_expect_proposition_nature_creation_local_habitation }
      it { is_expected.not_to be_expect_proposition_categorie_habitation }
      it { is_expected.not_to be_expect_proposition_categorie_dependance }
      it { is_expected.to     be_expect_proposition_categorie_professionnel }

      # Others
      it { is_expected.not_to be_display_situation_evaluation }
      it { is_expected.not_to be_display_situation_occupation }
      it { is_expected.not_to be_display_proposition_evaluation }
      it { is_expected.not_to be_display_proposition_occupation }
      it { is_expected.not_to be_display_proposition_exoneration }
      it { is_expected.not_to be_display_proposition_adresse }
    end

    context "without an 'omission_batie' anomalies" do
      let(:report) do
        build_stubbed(:report,
          form_type: "creation_local_professionnel",
          anomalies: %w[omission_batie])
      end

      # Situation MAJIC
      it { is_expected.not_to be_display_situation_majic }
      it { is_expected.not_to be_display_situation_annee_majic }
      it { is_expected.not_to be_display_situation_invariant }
      it { is_expected.to     be_display_situation_parcelle }
      it { is_expected.to     be_display_situation_adresse }
      it { is_expected.not_to be_display_situation_porte }
      it { is_expected.to     be_display_situation_proprietaire }

      it { is_expected.not_to be_require_situation_annee_majic }
      it { is_expected.not_to be_require_situation_invariant }
      it { is_expected.to     be_require_situation_parcelle }
      it { is_expected.to     be_require_situation_adresse }
      it { is_expected.not_to be_require_situation_porte }
      it { is_expected.to     be_require_situation_proprietaire }

      # Proposition creation
      it { is_expected.to     be_display_proposition_creation_local }
      it { is_expected.to     be_display_proposition_nature }
      it { is_expected.not_to be_display_proposition_nature_dependance }
      it { is_expected.to     be_display_proposition_categorie }
      it { is_expected.to     be_display_proposition_surface_reelle }
      it { is_expected.to     be_display_proposition_date_achevement }
      it { is_expected.not_to be_display_proposition_numero_permis }
      it { is_expected.not_to be_display_proposition_nature_travaux }

      it { is_expected.to     be_require_proposition_nature }
      it { is_expected.not_to be_require_proposition_nature_dependance }
      it { is_expected.to     be_require_proposition_categorie }
      it { is_expected.to     be_require_proposition_surface_reelle }
      it { is_expected.to     be_require_proposition_date_achevement }
      it { is_expected.not_to be_require_proposition_numero_permis }
      it { is_expected.not_to be_require_proposition_nature_travaux }

      it { is_expected.not_to be_expect_proposition_nature_habitation }
      it { is_expected.to     be_expect_proposition_nature_professionnel }
      it { is_expected.not_to be_expect_proposition_nature_creation_local_habitation }
      it { is_expected.not_to be_expect_proposition_categorie_habitation }
      it { is_expected.not_to be_expect_proposition_categorie_dependance }
      it { is_expected.to     be_expect_proposition_categorie_professionnel }

      # Others
      it { is_expected.not_to be_display_situation_evaluation }
      it { is_expected.not_to be_display_situation_occupation }
      it { is_expected.not_to be_display_proposition_evaluation }
      it { is_expected.not_to be_display_proposition_occupation }
      it { is_expected.not_to be_display_proposition_exoneration }
      it { is_expected.not_to be_display_proposition_adresse }
    end

    context "without an 'construction_neuve' anomalies" do
      let(:report) do
        build_stubbed(:report,
          form_type: "creation_local_professionnel",
          anomalies: %w[construction_neuve])
      end

      # Situation MAJIC
      it { is_expected.not_to be_display_situation_majic }
      it { is_expected.not_to be_display_situation_annee_majic }
      it { is_expected.not_to be_display_situation_invariant }
      it { is_expected.to     be_display_situation_parcelle }
      it { is_expected.to     be_display_situation_adresse }
      it { is_expected.not_to be_display_situation_porte }
      it { is_expected.to     be_display_situation_proprietaire }

      it { is_expected.not_to be_require_situation_annee_majic }
      it { is_expected.not_to be_require_situation_invariant }
      it { is_expected.to     be_require_situation_parcelle }
      it { is_expected.to     be_require_situation_adresse }
      it { is_expected.not_to be_require_situation_porte }
      it { is_expected.to     be_require_situation_proprietaire }

      # Proposition creation
      it { is_expected.to     be_display_proposition_creation_local }
      it { is_expected.to     be_display_proposition_nature }
      it { is_expected.not_to be_display_proposition_nature_dependance }
      it { is_expected.to     be_display_proposition_categorie }
      it { is_expected.to     be_display_proposition_surface_reelle }
      it { is_expected.to     be_display_proposition_date_achevement }
      it { is_expected.to     be_display_proposition_numero_permis }
      it { is_expected.to     be_display_proposition_nature_travaux }

      it { is_expected.to     be_require_proposition_nature }
      it { is_expected.not_to be_require_proposition_nature_dependance }
      it { is_expected.to     be_require_proposition_categorie }
      it { is_expected.to     be_require_proposition_surface_reelle }
      it { is_expected.to     be_require_proposition_date_achevement }
      it { is_expected.to     be_require_proposition_numero_permis }
      it { is_expected.to     be_require_proposition_nature_travaux }

      it { is_expected.not_to be_expect_proposition_nature_habitation }
      it { is_expected.to     be_expect_proposition_nature_professionnel }
      it { is_expected.not_to be_expect_proposition_nature_creation_local_habitation }
      it { is_expected.not_to be_expect_proposition_categorie_habitation }
      it { is_expected.not_to be_expect_proposition_categorie_dependance }
      it { is_expected.to     be_expect_proposition_categorie_professionnel }

      # Others
      it { is_expected.not_to be_display_situation_evaluation }
      it { is_expected.not_to be_display_situation_occupation }
      it { is_expected.not_to be_display_proposition_evaluation }
      it { is_expected.not_to be_display_proposition_occupation }
      it { is_expected.not_to be_display_proposition_exoneration }
      it { is_expected.not_to be_display_proposition_adresse }
    end
  end

  context "with an occupation_local_habitation" do
    let(:report) do
      build_stubbed(:report, form_type: "occupation_local_habitation")
    end

    # Situation MAJIC
    it { is_expected.to be_display_situation_majic }
    it { is_expected.to be_display_situation_annee_majic }
    it { is_expected.to be_display_situation_invariant }
    it { is_expected.to be_display_situation_parcelle }
    it { is_expected.to be_display_situation_adresse }
    it { is_expected.to be_display_situation_porte }
    it { is_expected.to be_display_situation_proprietaire }

    it { is_expected.to     be_require_situation_annee_majic }
    it { is_expected.to     be_require_situation_invariant }
    it { is_expected.to     be_require_situation_parcelle }
    it { is_expected.to     be_require_situation_adresse }
    it { is_expected.to     be_require_situation_porte }
    it { is_expected.not_to be_require_situation_proprietaire }

    # Situation evaluation
    it { is_expected.to     be_display_situation_evaluation }
    it { is_expected.not_to be_display_situation_date_mutation }
    it { is_expected.to     be_display_situation_affectation }
    it { is_expected.to     be_display_situation_nature }
    it { is_expected.to     be_display_situation_categorie }
    it { is_expected.to     be_display_situation_surface_reelle }
    it { is_expected.not_to be_display_other_situation_surface }
    it { is_expected.not_to be_display_situation_coefficient_localisation }
    it { is_expected.not_to be_display_situation_coefficient_entretien }
    it { is_expected.not_to be_display_situation_coefficient_situation }

    it { is_expected.not_to be_require_situation_date_mutation }
    it { is_expected.to     be_require_situation_affectation }
    it { is_expected.to     be_require_situation_nature }
    it { is_expected.to     be_require_situation_categorie }
    it { is_expected.not_to be_require_situation_surface_reelle }
    it { is_expected.not_to be_require_situation_coefficient_localisation }
    it { is_expected.not_to be_require_situation_coefficient_entretien }

    it { is_expected.to     be_expect_situation_nature_habitation }
    it { is_expected.not_to be_expect_situation_nature_professionnel }
    it { is_expected.to     be_expect_situation_categorie_habitation }
    it { is_expected.not_to be_expect_situation_categorie_professionnel }

    # Situation occupation
    it { is_expected.to     be_display_situation_occupation }
    it { is_expected.to     be_display_situation_nature_occupation }
    it { is_expected.not_to be_display_situation_majoration_rs }
    it { is_expected.not_to be_display_situation_annee_cfe }
    it { is_expected.not_to be_display_situation_vacance_fiscale }
    it { is_expected.not_to be_display_situation_nombre_annees_vacance }
    it { is_expected.not_to be_display_situation_siren_dernier_occupant }
    it { is_expected.not_to be_display_situation_nom_dernier_occupant }
    it { is_expected.not_to be_display_situation_vlf_cfe }
    it { is_expected.not_to be_display_situation_taxation_base_minimum }

    it { is_expected.to     be_require_situation_occupation_annee }
    it { is_expected.not_to be_require_situation_nature_occupation }
    it { is_expected.not_to be_require_situation_majoration_rs }
    it { is_expected.not_to be_require_situation_annee_cfe }
    it { is_expected.not_to be_require_situation_vacance_fiscale }
    it { is_expected.not_to be_require_situation_nombre_annees_vacance }
    it { is_expected.not_to be_require_situation_siren_dernier_occupant }
    it { is_expected.not_to be_require_situation_nom_dernier_occupant }
    it { is_expected.not_to be_require_situation_vlf_cfe }
    it { is_expected.not_to be_require_situation_taxation_base_minimum }

    # Proposition occupation
    it { is_expected.to     be_display_proposition_occupation }
    it { is_expected.to     be_display_proposition_nature_occupation }
    it { is_expected.to     be_display_proposition_date_occupation }
    it { is_expected.not_to be_display_proposition_erreur_tlv }
    it { is_expected.not_to be_display_proposition_erreur_thlv }
    it { is_expected.not_to be_display_proposition_meuble_tourisme }
    it { is_expected.not_to be_display_proposition_majoration_rs }
    it { is_expected.not_to be_display_proposition_nom_occupant }
    it { is_expected.not_to be_display_proposition_prenom_occupant }
    it { is_expected.not_to be_display_proposition_adresse_occupant }
    it { is_expected.not_to be_display_proposition_numero_siren }
    it { is_expected.not_to be_display_proposition_nom_societe }
    it { is_expected.not_to be_display_proposition_nom_enseigne }
    it { is_expected.not_to be_display_proposition_etablissement_principal }
    it { is_expected.not_to be_display_proposition_chantier_longue_duree }
    it { is_expected.not_to be_display_proposition_code_naf }
    it { is_expected.not_to be_display_proposition_date_debut_activite }

    it { is_expected.to     be_require_proposition_nature_occupation }
    it { is_expected.to     be_require_proposition_date_occupation }
    it { is_expected.not_to be_require_proposition_erreur_tlv }
    it { is_expected.not_to be_require_proposition_erreur_thlv }
    it { is_expected.not_to be_require_proposition_meuble_tourisme }
    it { is_expected.not_to be_require_proposition_majoration_rs }
    it { is_expected.not_to be_require_proposition_nom_occupant }
    it { is_expected.not_to be_require_proposition_prenom_occupant }
    it { is_expected.not_to be_require_proposition_numero_siren }
    it { is_expected.not_to be_require_proposition_nom_societe }
    it { is_expected.not_to be_require_proposition_etablissement_principal }
    it { is_expected.not_to be_require_proposition_chantier_longue_duree }
    it { is_expected.not_to be_require_proposition_code_naf }
    it { is_expected.not_to be_require_proposition_date_debut_activite }

    # Others
    it { is_expected.not_to be_display_proposition_evaluation }
    it { is_expected.not_to be_display_proposition_creation_local }
    it { is_expected.not_to be_display_proposition_exoneration }
    it { is_expected.not_to be_display_proposition_adresse }

    context "when setting situation_nature_occupation to a 'residence principale'" do
      let(:report) do
        build_stubbed(:report,
          form_type: "occupation_local_habitation",
          situation_nature_occupation: "RP")
      end

      # Situation occupatio
      it { is_expected.to     be_display_situation_occupation }
      it { is_expected.to     be_display_situation_nature_occupation }
      it { is_expected.not_to be_display_situation_majoration_rs }
      it { is_expected.not_to be_display_situation_annee_cfe }
      it { is_expected.not_to be_display_situation_vacance_fiscale }
      it { is_expected.not_to be_display_situation_nombre_annees_vacance }
      it { is_expected.not_to be_display_situation_siren_dernier_occupant }
      it { is_expected.not_to be_display_situation_nom_dernier_occupant }
      it { is_expected.not_to be_display_situation_vlf_cfe }
      it { is_expected.not_to be_display_situation_taxation_base_minimum }

      it { is_expected.to     be_require_situation_occupation_annee }
      it { is_expected.not_to be_require_situation_nature_occupation }
      it { is_expected.not_to be_require_situation_majoration_rs }
      it { is_expected.not_to be_require_situation_annee_cfe }
      it { is_expected.not_to be_require_situation_vacance_fiscale }
      it { is_expected.not_to be_require_situation_nombre_annees_vacance }
      it { is_expected.not_to be_require_situation_siren_dernier_occupant }
      it { is_expected.not_to be_require_situation_nom_dernier_occupant }
      it { is_expected.not_to be_require_situation_vlf_cfe }
      it { is_expected.not_to be_require_situation_taxation_base_minimum }
    end

    context "when setting situation_nature_occupation to a 'residence secondaire'" do
      let(:report) do
        build_stubbed(:report,
          form_type: "occupation_local_habitation",
          situation_nature_occupation: "RS")
      end

      # Situation occupation
      it { is_expected.to     be_display_situation_occupation }
      it { is_expected.to     be_display_situation_nature_occupation }
      it { is_expected.to     be_display_situation_majoration_rs }
      it { is_expected.not_to be_display_situation_annee_cfe }
      it { is_expected.not_to be_display_situation_vacance_fiscale }
      it { is_expected.not_to be_display_situation_nombre_annees_vacance }
      it { is_expected.not_to be_display_situation_siren_dernier_occupant }
      it { is_expected.not_to be_display_situation_nom_dernier_occupant }
      it { is_expected.not_to be_display_situation_vlf_cfe }
      it { is_expected.not_to be_display_situation_taxation_base_minimum }

      it { is_expected.to     be_require_situation_occupation_annee }
      it { is_expected.not_to be_require_situation_nature_occupation }
      it { is_expected.to     be_require_situation_majoration_rs }
      it { is_expected.not_to be_require_situation_annee_cfe }
      it { is_expected.not_to be_require_situation_vacance_fiscale }
      it { is_expected.not_to be_require_situation_nombre_annees_vacance }
      it { is_expected.not_to be_require_situation_siren_dernier_occupant }
      it { is_expected.not_to be_require_situation_nom_dernier_occupant }
      it { is_expected.not_to be_require_situation_vlf_cfe }
      it { is_expected.not_to be_require_situation_taxation_base_minimum }

      # Proposition occupation
      it { is_expected.not_to be_display_proposition_erreur_tlv }
      it { is_expected.not_to be_display_proposition_erreur_thlv }

      it { is_expected.not_to be_require_proposition_erreur_tlv }
      it { is_expected.not_to be_require_proposition_erreur_thlv }
    end

    context "when setting situation_nature_occupation to a 'vacant'" do
      let(:report) do
        build_stubbed(:report,
          form_type: "occupation_local_habitation",
          situation_nature_occupation: "vacant")
      end

      # Situation occupation
      it { is_expected.to     be_display_situation_occupation }
      it { is_expected.to     be_display_situation_nature_occupation }
      it { is_expected.not_to be_display_situation_majoration_rs }
      it { is_expected.not_to be_display_situation_annee_cfe }
      it { is_expected.not_to be_display_situation_vacance_fiscale }
      it { is_expected.not_to be_display_situation_nombre_annees_vacance }
      it { is_expected.not_to be_display_situation_siren_dernier_occupant }
      it { is_expected.not_to be_display_situation_nom_dernier_occupant }
      it { is_expected.not_to be_display_situation_vlf_cfe }
      it { is_expected.not_to be_display_situation_taxation_base_minimum }

      it { is_expected.to     be_require_situation_occupation_annee }
      it { is_expected.not_to be_require_situation_nature_occupation }
      it { is_expected.not_to be_require_situation_majoration_rs }
      it { is_expected.not_to be_require_situation_annee_cfe }
      it { is_expected.not_to be_require_situation_vacance_fiscale }
      it { is_expected.not_to be_require_situation_nombre_annees_vacance }
      it { is_expected.not_to be_require_situation_siren_dernier_occupant }
      it { is_expected.not_to be_require_situation_nom_dernier_occupant }
      it { is_expected.not_to be_require_situation_vlf_cfe }
      it { is_expected.not_to be_require_situation_taxation_base_minimum }

      # Proposition occupation
      it { is_expected.not_to be_display_proposition_erreur_tlv }
      it { is_expected.not_to be_display_proposition_erreur_thlv }

      it { is_expected.not_to be_require_proposition_erreur_tlv }
      it { is_expected.not_to be_require_proposition_erreur_thlv }
    end

    context "when setting situation_nature_occupation to a 'vacant_tlv'" do
      let(:report) do
        build_stubbed(:report,
          form_type: "occupation_local_habitation",
          situation_nature_occupation: "vacant_tlv")
      end

      # Proposition occupation
      it { is_expected.to     be_display_proposition_erreur_tlv }
      it { is_expected.not_to be_display_proposition_erreur_thlv }

      it { is_expected.to     be_require_proposition_erreur_tlv }
      it { is_expected.not_to be_require_proposition_erreur_thlv }
    end

    context "when setting situation_nature_occupation to a 'vacant_thlv'" do
      let(:report) do
        build_stubbed(:report,
          form_type: "occupation_local_habitation",
          situation_nature_occupation: "vacant_thlv")
      end

      # Proposition occupation
      it { is_expected.not_to be_display_proposition_erreur_tlv }
      it { is_expected.to     be_display_proposition_erreur_thlv }

      it { is_expected.not_to be_require_proposition_erreur_tlv }
      it { is_expected.to     be_require_proposition_erreur_thlv }
    end

    context "when setting proposition_nature_occupation to a 'residence principale'" do
      let(:report) do
        build_stubbed(:report,
          form_type: "occupation_local_habitation",
          proposition_nature_occupation: "RP")
      end

      # Proposition occupation
      it { is_expected.to     be_display_proposition_occupation }
      it { is_expected.to     be_display_proposition_nature_occupation }
      it { is_expected.to     be_display_proposition_date_occupation }
      it { is_expected.not_to be_display_proposition_erreur_tlv }
      it { is_expected.not_to be_display_proposition_erreur_thlv }
      it { is_expected.to     be_display_proposition_meuble_tourisme }
      it { is_expected.not_to be_display_proposition_majoration_rs }
      it { is_expected.to     be_display_proposition_nom_occupant }
      it { is_expected.to     be_display_proposition_prenom_occupant }
      it { is_expected.to     be_display_proposition_adresse_occupant }
      it { is_expected.not_to be_display_proposition_numero_siren }
      it { is_expected.not_to be_display_proposition_nom_societe }
      it { is_expected.not_to be_display_proposition_nom_enseigne }
      it { is_expected.not_to be_display_proposition_etablissement_principal }
      it { is_expected.not_to be_display_proposition_chantier_longue_duree }
      it { is_expected.not_to be_display_proposition_code_naf }
      it { is_expected.not_to be_display_proposition_date_debut_activite }

      it { is_expected.to     be_require_proposition_nature_occupation }
      it { is_expected.to     be_require_proposition_date_occupation }
      it { is_expected.not_to be_require_proposition_erreur_tlv }
      it { is_expected.not_to be_require_proposition_erreur_thlv }
      it { is_expected.to     be_require_proposition_meuble_tourisme }
      it { is_expected.not_to be_require_proposition_majoration_rs }
      it { is_expected.to     be_require_proposition_nom_occupant }
      it { is_expected.to     be_require_proposition_prenom_occupant }
      it { is_expected.not_to be_require_proposition_numero_siren }
      it { is_expected.not_to be_require_proposition_nom_societe }
      it { is_expected.not_to be_require_proposition_etablissement_principal }
      it { is_expected.not_to be_require_proposition_chantier_longue_duree }
      it { is_expected.not_to be_require_proposition_code_naf }
      it { is_expected.not_to be_require_proposition_date_debut_activite }
    end

    context "when setting proposition_nature_occupation to a 'residence secondaire'" do
      let(:report) do
        build_stubbed(:report,
          form_type: "occupation_local_habitation",
          proposition_nature_occupation: "RS")
      end

      # Proposition occupation
      it { is_expected.to     be_display_proposition_occupation }
      it { is_expected.to     be_display_proposition_nature_occupation }
      it { is_expected.to     be_display_proposition_date_occupation }
      it { is_expected.not_to be_display_proposition_erreur_tlv }
      it { is_expected.not_to be_display_proposition_erreur_thlv }
      it { is_expected.to     be_display_proposition_meuble_tourisme }
      it { is_expected.to     be_display_proposition_majoration_rs }
      it { is_expected.to     be_display_proposition_nom_occupant }
      it { is_expected.to     be_display_proposition_prenom_occupant }
      it { is_expected.to     be_display_proposition_adresse_occupant }
      it { is_expected.not_to be_display_proposition_numero_siren }
      it { is_expected.not_to be_display_proposition_nom_societe }
      it { is_expected.not_to be_display_proposition_nom_enseigne }
      it { is_expected.not_to be_display_proposition_etablissement_principal }
      it { is_expected.not_to be_display_proposition_chantier_longue_duree }
      it { is_expected.not_to be_display_proposition_code_naf }
      it { is_expected.not_to be_display_proposition_date_debut_activite }

      it { is_expected.to     be_require_proposition_nature_occupation }
      it { is_expected.to     be_require_proposition_date_occupation }
      it { is_expected.not_to be_require_proposition_erreur_tlv }
      it { is_expected.not_to be_require_proposition_erreur_thlv }
      it { is_expected.to     be_require_proposition_meuble_tourisme }
      it { is_expected.to     be_require_proposition_majoration_rs }
      it { is_expected.to     be_require_proposition_nom_occupant }
      it { is_expected.to     be_require_proposition_prenom_occupant }
      it { is_expected.not_to be_require_proposition_numero_siren }
      it { is_expected.not_to be_require_proposition_nom_societe }
      it { is_expected.not_to be_require_proposition_etablissement_principal }
      it { is_expected.not_to be_require_proposition_chantier_longue_duree }
      it { is_expected.not_to be_require_proposition_code_naf }
      it { is_expected.not_to be_require_proposition_date_debut_activite }
    end

    context "when setting proposition_nature_occupation to a 'vacant'" do
      let(:report) do
        build_stubbed(:report,
          form_type: "occupation_local_habitation",
          proposition_nature_occupation: "vacant")
      end

      # Proposition occupation
      it { is_expected.to     be_display_proposition_occupation }
      it { is_expected.to     be_display_proposition_nature_occupation }
      it { is_expected.to     be_display_proposition_date_occupation }
      it { is_expected.not_to be_display_proposition_erreur_tlv }
      it { is_expected.not_to be_display_proposition_erreur_thlv }
      it { is_expected.not_to be_display_proposition_meuble_tourisme }
      it { is_expected.not_to be_display_proposition_majoration_rs }
      it { is_expected.not_to be_display_proposition_nom_occupant }
      it { is_expected.not_to be_display_proposition_prenom_occupant }
      it { is_expected.not_to be_display_proposition_adresse_occupant }
      it { is_expected.not_to be_display_proposition_numero_siren }
      it { is_expected.not_to be_display_proposition_nom_societe }
      it { is_expected.not_to be_display_proposition_nom_enseigne }
      it { is_expected.not_to be_display_proposition_etablissement_principal }
      it { is_expected.not_to be_display_proposition_chantier_longue_duree }
      it { is_expected.not_to be_display_proposition_code_naf }
      it { is_expected.not_to be_display_proposition_date_debut_activite }

      it { is_expected.to     be_require_proposition_nature_occupation }
      it { is_expected.to     be_require_proposition_date_occupation }
      it { is_expected.not_to be_require_proposition_erreur_tlv }
      it { is_expected.not_to be_require_proposition_erreur_thlv }
      it { is_expected.not_to be_require_proposition_meuble_tourisme }
      it { is_expected.not_to be_require_proposition_majoration_rs }
      it { is_expected.not_to be_require_proposition_nom_occupant }
      it { is_expected.not_to be_require_proposition_prenom_occupant }
      it { is_expected.not_to be_require_proposition_numero_siren }
      it { is_expected.not_to be_require_proposition_nom_societe }
      it { is_expected.not_to be_require_proposition_etablissement_principal }
      it { is_expected.not_to be_require_proposition_chantier_longue_duree }
      it { is_expected.not_to be_require_proposition_code_naf }
      it { is_expected.not_to be_require_proposition_date_debut_activite }
    end
  end

  context "with an occupation_local_professionnel" do
    let(:report) do
      build_stubbed(:report, form_type: "occupation_local_professionnel")
    end

    # Situation MAJIC
    it { is_expected.to be_display_situation_majic }
    it { is_expected.to be_display_situation_annee_majic }
    it { is_expected.to be_display_situation_invariant }
    it { is_expected.to be_display_situation_parcelle }
    it { is_expected.to be_display_situation_adresse }
    it { is_expected.to be_display_situation_porte }
    it { is_expected.to be_display_situation_proprietaire }

    it { is_expected.to     be_require_situation_annee_majic }
    it { is_expected.to     be_require_situation_invariant }
    it { is_expected.to     be_require_situation_parcelle }
    it { is_expected.to     be_require_situation_adresse }
    it { is_expected.to     be_require_situation_porte }
    it { is_expected.not_to be_require_situation_proprietaire }

    # Situation evaluation
    it { is_expected.to     be_display_situation_evaluation }
    it { is_expected.not_to be_display_situation_date_mutation }
    it { is_expected.to     be_display_situation_affectation }
    it { is_expected.to     be_display_situation_nature }
    it { is_expected.to     be_display_situation_categorie }
    it { is_expected.to     be_display_situation_surface_reelle }
    it { is_expected.not_to be_display_other_situation_surface }
    it { is_expected.not_to be_display_situation_coefficient_localisation }
    it { is_expected.not_to be_display_situation_coefficient_entretien }
    it { is_expected.not_to be_display_situation_coefficient_situation }

    it { is_expected.not_to be_require_situation_date_mutation }
    it { is_expected.to     be_require_situation_affectation }
    it { is_expected.to     be_require_situation_nature }
    it { is_expected.to     be_require_situation_categorie }
    it { is_expected.to     be_require_situation_surface_reelle }
    it { is_expected.not_to be_require_situation_coefficient_localisation }
    it { is_expected.not_to be_require_situation_coefficient_entretien }

    it { is_expected.not_to be_expect_situation_nature_habitation }
    it { is_expected.to     be_expect_situation_nature_professionnel }
    it { is_expected.not_to be_expect_situation_categorie_habitation }
    it { is_expected.to     be_expect_situation_categorie_professionnel }

    # Situation occupation
    it { is_expected.to     be_display_situation_occupation }
    it { is_expected.not_to be_display_situation_nature_occupation }
    it { is_expected.not_to be_display_situation_majoration_rs }
    it { is_expected.to     be_display_situation_annee_cfe }
    it { is_expected.to     be_display_situation_vacance_fiscale }
    it { is_expected.not_to be_display_situation_nombre_annees_vacance }
    it { is_expected.to     be_display_situation_siren_dernier_occupant }
    it { is_expected.to     be_display_situation_nom_dernier_occupant }
    it { is_expected.to     be_display_situation_vlf_cfe }
    it { is_expected.to     be_display_situation_taxation_base_minimum }

    it { is_expected.not_to be_require_situation_occupation_annee }
    it { is_expected.not_to be_require_situation_nature_occupation }
    it { is_expected.not_to be_require_situation_majoration_rs }
    it { is_expected.to     be_require_situation_annee_cfe }
    it { is_expected.to     be_require_situation_vacance_fiscale }
    it { is_expected.not_to be_require_situation_nombre_annees_vacance }
    it { is_expected.to     be_require_situation_siren_dernier_occupant }
    it { is_expected.to     be_require_situation_nom_dernier_occupant }
    it { is_expected.to     be_require_situation_vlf_cfe }
    it { is_expected.to     be_require_situation_taxation_base_minimum }

    # Proposition occupation
    it { is_expected.to     be_display_proposition_occupation }
    it { is_expected.not_to be_display_proposition_nature_occupation }
    it { is_expected.not_to be_display_proposition_date_occupation }
    it { is_expected.not_to be_display_proposition_erreur_tlv }
    it { is_expected.not_to be_display_proposition_erreur_thlv }
    it { is_expected.not_to be_display_proposition_meuble_tourisme }
    it { is_expected.not_to be_display_proposition_majoration_rs }
    it { is_expected.not_to be_display_proposition_nom_occupant }
    it { is_expected.not_to be_display_proposition_prenom_occupant }
    it { is_expected.not_to be_display_proposition_adresse_occupant }
    it { is_expected.to     be_display_proposition_numero_siren }
    it { is_expected.to     be_display_proposition_nom_societe }
    it { is_expected.to     be_display_proposition_nom_enseigne }
    it { is_expected.to     be_display_proposition_etablissement_principal }
    it { is_expected.to     be_display_proposition_chantier_longue_duree }
    it { is_expected.to     be_display_proposition_code_naf }
    it { is_expected.to     be_display_proposition_date_debut_activite }

    it { is_expected.not_to be_require_proposition_nature_occupation }
    it { is_expected.not_to be_require_proposition_date_occupation }
    it { is_expected.not_to be_require_proposition_erreur_tlv }
    it { is_expected.not_to be_require_proposition_erreur_thlv }
    it { is_expected.not_to be_require_proposition_meuble_tourisme }
    it { is_expected.not_to be_require_proposition_majoration_rs }
    it { is_expected.not_to be_require_proposition_nom_occupant }
    it { is_expected.not_to be_require_proposition_prenom_occupant }
    it { is_expected.to     be_require_proposition_numero_siren }
    it { is_expected.to     be_require_proposition_nom_societe }
    it { is_expected.to     be_require_proposition_etablissement_principal }
    it { is_expected.to     be_require_proposition_chantier_longue_duree }
    it { is_expected.to     be_require_proposition_code_naf }
    it { is_expected.to     be_require_proposition_date_debut_activite }

    # Others
    it { is_expected.not_to be_display_proposition_evaluation }
    it { is_expected.not_to be_display_proposition_creation_local }
    it { is_expected.not_to be_display_proposition_exoneration }
    it { is_expected.not_to be_display_proposition_adresse }

    context "when setting situation_vacance_fiscale to 'true'" do
      let(:report) do
        build_stubbed(:report,
          form_type: "occupation_local_professionnel",
          situation_vacance_fiscale: true)
      end

      it { is_expected.to be_display_situation_nombre_annees_vacance }
      it { is_expected.to be_require_situation_nombre_annees_vacance }
    end

    context "when setting situation_vacance_fiscale to 'false'" do
      let(:report) do
        build_stubbed(:report,
          form_type: "occupation_local_professionnel",
          situation_vacance_fiscale: false)
      end

      it { is_expected.not_to be_display_situation_nombre_annees_vacance }
      it { is_expected.not_to be_require_situation_nombre_annees_vacance }
    end
  end
end
