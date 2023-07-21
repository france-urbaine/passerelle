# frozen_string_literal: true

require "rails_helper"

RSpec.describe Offices::UpdateService do
  subject(:service) do
    described_class.new(office, attributes)
  end

  let!(:office) { create(:office, competences: %w[evaluation_local_professionnel]) }

  let(:attributes) do
    { competences: %w[evaluation_local_professionnel creation_local_professionnel] }
  end

  it "returns a successful result" do
    expect(service.save).to be_successful
  end

  it "updates the office" do
    expect { service.save }
      .to change(office, :updated_at)
      .and change(office, :competences)
  end

  context "with invalid arguments" do
    let(:attributes) do
      { name: "" }
    end

    it "returns a failed result with errors" do
      result = service.save

      aggregate_failures do
        expect(result).to be_failed
        expect(result.errors).to be_any
      end
    end

    it "doesn't update the office" do
      expect { service.save }
        .not_to change(office, :updated_at)
    end
  end
end
