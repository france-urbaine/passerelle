# frozen_string_literal: true

require "rails_helper"

RSpec.describe Users::CreateService do
  subject(:service) do
    described_class.new(user, attributes, invited_by: current_user)
  end

  let!(:user)         { User.new }
  let!(:current_user) { create(:user) }

  let!(:attributes) do
    {
      first_name:         Faker::Name.first_name,
      last_name:          Faker::Name.last_name,
      email:              Faker::Internet.email,
      organization_admin: true
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

    expect(user).to have_attributes(
      first_name:         attributes[:first_name],
      last_name:          attributes[:last_name],
      email:              attributes[:email],
      organization_admin: attributes[:organization_admin],
      organization:       current_user.organization,
      inviter:            current_user
    )
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

    it "creates the user" do
      expect { service.save }
        .to  change(User, :count).by(1)
        .and change(user, :persisted?).from(false).to(true)
    end

    it "assigns expected attributes" do
      service.save
      user.reload

      expect(user).to have_attributes(
        organization: ddfip,
        offices:      offices[1..2]
      )
    end
  end
end
