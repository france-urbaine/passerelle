# frozen_string_literal: true

require "rails_helper"

RSpec.describe Users::UpdateService do
  subject(:service) do
    described_class.new(user, attributes)
  end

  let!(:user) { create(:user) }
  let!(:attributes) do
    {
      first_name: Faker::Name.first_name,
      last_name:  Faker::Name.last_name
    }
  end

  let(:other_organization) do
    create(%i[ddfip publisher collectivity].sample)
  end

  it "returns a successful result" do
    expect(service.save).to be_successful
  end

  it "updates the user's attributes" do
    expect { service.save }
      .to  change(user, :updated_at)
      .and change(user, :first_name).to(attributes[:first_name])
      .and change(user, :last_name).to(attributes[:last_name])
  end

  context "with invalid arguments" do
    let(:attributes) do
      { email: "" }
    end

    it "returns a failed result with errors" do
      result = service.save

      aggregate_failures do
        expect(result).to be_failed
        expect(result.errors).to be_any
      end
    end

    it "doesn't update the collectivity" do
      expect { service.save }
        .not_to change(user, :updated_at)
    end
  end

  describe "assigning an organization" do
    context "with organization_type & organization_id" do
      let(:attributes) do
        {
          organization_type: other_organization.class.name,
          organization_id:   other_organization.id
        }
      end

      it "updates user organization" do
        expect { service.save }
          .to  change(user, :updated_at)
          .and change(user, :organization).to(other_organization)
      end
    end

    context "with organization_data in JSON" do
      let(:attributes) do
        {
          organization_data: {
            type: other_organization.class.name,
            id:   other_organization.id
          }.to_json
        }
      end

      it "updates user organization" do
        expect { service.save }
          .to  change(user, :updated_at)
          .and change(user, :organization).to(other_organization)
      end
    end

    context "with organization_type and organization_name" do
      context "when assigning a DDFIP" do
        let(:other_organization) { create(:ddfip) }
        let(:attributes) do
          {
            organization_type: "DDFIP",
            organization_name: other_organization.name
          }
        end

        it "updates user organization" do
          expect { service.save }
            .to  change(user, :updated_at)
            .and change(user, :organization).to(other_organization)
        end
      end

      context "when assigning a publisher" do
        let(:other_organization) { create(:publisher) }
        let(:attributes) do
          {
            organization_type: "Publisher",
            organization_name: other_organization.name
          }
        end

        it "updates user organization" do
          expect { service.save }
            .to  change(user, :updated_at)
            .and change(user, :organization).to(other_organization)
        end
      end

      context "when assigning a collectivity" do
        let(:other_organization) { create(:collectivity) }
        let(:attributes) do
          {
            organization_type: "Collectivity",
            organization_name: other_organization.name
          }
        end

        it "updates user organization" do
          expect { service.save }
            .to  change(user, :updated_at)
            .and change(user, :organization).to(other_organization)
        end
      end
    end
  end

  describe "assigning offices" do
    let(:ddfips) { create_list(:ddfip, 2) }
    let(:user)   { create(:user, organization: ddfips[0]) }

    let(:offices) do
      create_list(:office, 3, ddfip: ddfips[0]) +
        create_list(:office, 2, ddfip: ddfips[1])
    end

    it "updates user offices using only offices of its organization" do
      service = described_class.new(user, {
        office_ids: offices[0..1] + offices[4..4]
      })

      service.save

      expect(user.offices.reload.to_a)
        .to have(2).offices
        .and include(offices[0])
        .and include(offices[1])
    end

    it "updates user offices using offices of its new organization" do
      service = described_class.new(user, {
        organization_type: "DDFIP",
        organization_name: ddfips[1].name,
        office_ids:        offices[0..1] + offices[4..4]
      })

      service.save

      expect(user.offices.reload.to_a).to eq(offices[4..4])
    end

    it "doesn't update user offices when user validations failed" do
      service = described_class.new(user, {
        organization_type: "DDFIP",
        organization_name: ddfips[1].name,
        office_ids:        offices[4..4],
        email: "@"
      })

      service.save

      expect(user.offices.reload.to_a).to eq([])
    end

    it "resets user offices when it leaves an organization" do
      user.offices = offices

      service = described_class.new(user, {
        organization_type: other_organization.class.name,
        organization_id:   other_organization.id
      })

      service.save

      expect(user.offices.reload.to_a).to eq([])
    end
  end
end
