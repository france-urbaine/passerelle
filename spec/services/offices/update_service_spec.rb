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

  it "updates the office's attributes" do
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

  context "with users IDs" do
    let!(:ddfips) { create_list(:ddfip, 2) }
    let!(:office) { create(:office, ddfip: ddfips[0]) }

    let!(:users) do
      [
        create(:user, organization: ddfips[0]),
        create(:user, organization: ddfips[0]),
        create(:user, organization: ddfips[0]),
        create(:user, organization: ddfips[1]),
        create(:user, organization: ddfips[1])
      ]
    end

    it "assigns only users belonging to the same DDFIP" do
      service = described_class.new(office, { user_ids: users[1..4].map(&:id) })
      service.save
      office.reload

      expect(office.users.to_a)
        .to have(2).users
        .and include(users[1], users[2])
    end

    it "assigns only users belonging to the newly assigned DDFIP" do
      service = described_class.new(office, {
        ddfip_name: ddfips[1].name,
        user_ids:   users[1..4].map(&:id)
      })
      service.save
      office.reload

      expect(office.users.to_a)
        .to have(2).users
        .and include(users[3], users[4])
    end
  end

  context "with communes IDs" do
    let!(:departement) { create(:departement) }
    let!(:ddfip)       { create(:ddfip, departement: departement) }
    let!(:office)      { create(:office, ddfip: ddfip) }
    let!(:communes) do
      [
        create(:commune, departement: departement),
        create(:commune, departement: departement),
        create(:commune, departement: departement),
        create(:commune),
        create(:commune)
      ]
    end

    it "assigns only communes belonging to the same departement" do
      service = described_class.new(office, { commune_ids: communes[1..4].map(&:code_insee) })
      service.save
      office.reload

      expect(office.communes.to_a)
        .to have(2).communes
        .and include(communes[1], communes[2])
    end
  end
end
