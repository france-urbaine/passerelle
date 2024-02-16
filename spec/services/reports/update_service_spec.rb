# frozen_string_literal: true

require "rails_helper"

RSpec.describe Reports::UpdateService do
  subject(:service) do
    described_class.new(report, attributes)
  end

  let(:report)     { create(:report, :creation_local_habitation) }
  let(:attributes) { required_attributes }

  let(:required_attributes) do
    {
      anomalies: ["omission_batie"],
      date_constat: Time.current,
      situation_proprietaire: "Doe",
      situation_numero_ordre_proprietaire: "A12345",
      situation_parcelle: "AA 0000",
      situation_numero_voie: "1",
      situation_libelle_voie: "rue de la Liberté",
      situation_code_rivoli: "0000",
      proposition_nature: "AP",
      proposition_categorie: "1",
      proposition_surface_reelle: "70",
      proposition_date_achevement: "2023-01-01"
    }
  end

  context "when report is draft and updated with required attributes" do
    it "updates the report as ready" do
      expect { service.save }
        .to  ret(be_a(Result::Success))
        .and change(report, :updated_at)
        .and change(report, :state).to("ready")
        .and change(report, :completed_at).to(be_present)
    end
  end

  context "when report is draft and updated with missing attributes" do
    let(:attributes) do
      required_attributes.excluding(:situation_parcelle)
    end

    it "updates the report but it keep it as draft" do
      expect { service.save }
        .to  ret(be_a(Result::Success))
        .and change(report, :updated_at)
        .and not_change(report, :state).from("draft")
        .and not_change(report, :completed_at).from(nil)
    end
  end

  context "when report is already completed and updated with required attributes" do
    let(:report) { create(:report, :creation_local_habitation, :ready) }

    it "updates the report back to draft" do
      expect { service.save }
        .to  ret(be_a(Result::Success))
        .and change(report, :updated_at)
        .and not_change(report, :state).from("ready")
        .and not_change(report, :completed_at)
    end
  end

  context "when report is already completed but updated with missing attributes" do
    let(:report) { create(:report, :creation_local_habitation, :ready, **required_attributes) }

    let(:attributes) do
      required_attributes.merge(situation_parcelle: nil)
    end

    it "updates the report back to draft" do
      expect { service.save }
        .to  ret(be_a(Result::Success))
        .and change(report, :updated_at)
        .and change(report, :state).to("draft")
        .and change(report, :completed_at).to(nil)
    end
  end

  context "with validation errors at model level" do
    let(:attributes) do
      {
        situation_parcelle: "AA"
      }
    end

    it "return a failure monad with errors", :aggregate_failures do
      result = service.save

      expect(result).to be_a(Result::Failure)
      expect(result.errors).to satisfy { |errors| errors.of_kind?(:situation_parcelle, :invalid) }
    end
  end
end
