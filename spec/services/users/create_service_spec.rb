# frozen_string_literal: true

require "rails_helper"

RSpec.describe Users::CreateService do
  subject(:service) do
    described_class.new(user, attributes, invited_by: current_user, organization: organization)
  end

  let(:user)          { User.new }
  let!(:current_user) { create(:user) }
  let!(:organization) { nil }
  let(:attributes) do
    {
      first_name:         Faker::Name.first_name,
      last_name:          Faker::Name.last_name,
      email:              Faker::Internet.email,
      organization_admin: true
    }
  end

  context "without organization" do
    it "returns a failed result with errors" do
      result = service.save

      aggregate_failures do
        expect(result).to be_failed
        expect(result.errors).to include(:organization)
      end
    end

    it "doesn't create an user" do
      expect { service.save }
        .to  not_change(User, :count)
        .and not_change(user, :persisted?).from(false)
    end
  end

  context "with organization in attributes" do
    let!(:expected_organization) { create(%i[publisher collectivity ddfip].sample) }
    let!(:attributes) do
      super().merge(
        organization_type: expected_organization.class.name,
        organization_id:   expected_organization.id
      )
    end

    it "returns a successful result" do
      expect(service.save).to be_successful
    end

    it "creates the user" do
      expect { service.save }
        .to  change(User, :count).by(1)
        .and change(user, :persisted?).from(false).to(true)
    end

    it "assigns expected attributes" do
      service.save
      user.reload

      expect(user).to have_attributes(
        first_name:         attributes[:first_name],
        last_name:          attributes[:last_name],
        email:              attributes[:email],
        organization_admin: attributes[:organization_admin],
        organization:       expected_organization,
        inviter:            current_user
      )
    end
  end

  context "with organization and offices attributes" do
    let(:ddfip)   { create(:ddfip) }
    let(:offices) { create_list(:office, 3, ddfip: ddfip) }

    let(:attributes) do
      super().merge(
        organization_data: { type: "DDFIP", id: ddfip.id }.to_json,
        office_ids:        offices[1..2].map(&:id)
      )
    end

    it "returns a successful result" do
      expect(service.save).to be_successful
    end

    it "creates the user" do
      expect { service.save }
        .to  change(User, :count).by(1)
        .and change(user, :persisted?).from(false).to(true)
    end

    it "assigns expected attributes" do
      service.save
      user.reload

      aggregate_failures do
        expect(user.organization).to eq(ddfip)
        expect(user.offices).to have(2).offices.and include(*offices[1..2])
      end
    end
  end

  context "with organization passed as argument" do
    let!(:organization) { create(%i[publisher collectivity ddfip].sample) }

    it "returns a successful result" do
      expect(service.save).to be_successful
    end

    it "creates the user" do
      expect { service.save }
        .to  change(User, :count).by(1)
        .and change(user, :persisted?).from(false).to(true)
    end

    it "assigns expected attributes" do
      service.save
      user.reload

      expect(user).to have_attributes(
        first_name:         attributes[:first_name],
        last_name:          attributes[:last_name],
        email:              attributes[:email],
        organization_admin: attributes[:organization_admin],
        organization:       organization,
        inviter:            current_user
      )
    end

    context "with another organization in attributes" do
      let!(:another_organization) { create(%i[publisher collectivity ddfip].sample) }
      let(:attributes) do
        super().merge(
          organization_type: another_organization.class.name,
          organization_id:   another_organization.id
        )
      end

      it "ignores organization in attributes to assign the one passed as argument" do
        service.save
        user.reload
        expect(user.organization).to eq(organization)
      end
    end
  end

  context "with a supervisor" do
    let!(:current_user) { create(:user, :ddfip, :supervisor) }
    let!(:organization) { current_user.organization }

    let(:attributes) do
      {
        first_name:              Faker::Name.first_name,
        last_name:               Faker::Name.last_name,
        email:                   Faker::Internet.email,
        office_users_attributes: [
          { office_id: current_user.offices.first.id }
        ]
      }
    end

    it "returns a successful result" do
      expect(service.save).to be_successful
    end

    it "creates the user" do
      expect { service.save }
        .to  change(User, :count).by(1)
        .and change(user, :persisted?).from(false).to(true)
    end

    it "assigns expected attributes" do
      service.save
      user.reload

      aggregate_failures do
        expect(user.organization).to eq(organization)
        expect(user.offices).to have(1).offices.and include(current_user.offices.first)
      end
    end

    context "with invalid office_users_attributes" do
      let(:attributes) do
        {
          first_name:              Faker::Name.first_name,
          last_name:               Faker::Name.last_name,
          email:                   Faker::Internet.email,
          office_users_attributes: []
        }
      end

      it "returns an error result" do
        expect(service.save).to be_failed
      end
    end
  end
end
