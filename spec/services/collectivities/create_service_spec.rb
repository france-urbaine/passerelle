# frozen_string_literal: true

require "rails_helper"

RSpec.describe Collectivities::CreateService do
  subject(:service) do
    described_class.new(collectivity, attributes)
  end

  let(:collectivity) { Collectivity.new }
  let(:publisher) { create(:publisher) }
  let(:epci)      { create(:epci) }

  let(:attributes) do
    {
      territory_type:     "EPCI",
      territory_id:       epci.id,
      publisher_id:       publisher.id,
      name:               "Nouvelle collectivité",
      siren:              Faker::Company.unique.french_siren_number,
      contact_first_name: Faker::Name.first_name,
      contact_last_name:  Faker::Name.last_name,
      contact_email:      Faker::Internet.email,
      contact_phone:      Faker::PhoneNumber.phone_number
    }
  end

  it "returns a successful result" do
    expect(service.save).to be_successful
  end

  it "creates the collectivity" do
    expect { service.save }
      .to  change(Collectivity, :count).by(1)
      .and change(collectivity, :persisted?).from(false).to(true)
  end

  it "assigns expected attributes" do
    service.save
    collectivity.reload

    expect(collectivity).to have_attributes(
      territory: epci,
      publisher: publisher,
      siren:     attributes[:siren],
      name:      attributes[:name]
    )
  end

  context "with invalid arguments" do
    let(:attributes) do
      {
        name: "Nouvelle collectivité"
      }
    end

    it "returns a failed result with errors" do
      result = service.save

      aggregate_failures do
        expect(result).to be_failed
        expect(result.errors).to be_any
      end
    end

    it "doesn't create a collectivity" do
      expect { service.save }
        .to  not_change(Collectivity, :count)
        .and not_change(collectivity, :persisted?).from(false)
    end
  end

  context "with a given publisher" do
    subject(:service) do
      described_class.new(collectivity, attributes, publisher: another_publisher)
    end

    let(:another_publisher) { create(:publisher) }

    it "creates a collectivity with the given publisher instead of the one passed" do
      expect { service.save && collectivity.reload }
        .to change(collectivity, :publisher).to(another_publisher)
    end
  end

  context "when using territory_data in JSON" do
    let(:attributes) do
      {
        territory_data:     { type: "EPCI", id: epci.id }.to_json,
        publisher_id:       publisher.id,
        name:               "Nouvelle collectivité",
        siren:              Faker::Company.unique.french_siren_number,
        contact_first_name: Faker::Name.first_name,
        contact_last_name:  Faker::Name.last_name,
        contact_email:      Faker::Internet.email,
        contact_phone:      Faker::PhoneNumber.phone_number
      }
    end

    it "assigns expected territory" do
      expect { service.save }
        .to change(collectivity, :territory).to(epci)
    end
  end

  context "when using territory_code" do
    let(:attributes) do
      {
        territory_type:     "EPCI",
        territory_code:     epci.siren,
        publisher_id:       publisher.id,
        name:               "Nouvelle collectivité",
        siren:              Faker::Company.unique.french_siren_number,
        contact_first_name: Faker::Name.first_name,
        contact_last_name:  Faker::Name.last_name,
        contact_email:      Faker::Internet.email,
        contact_phone:      Faker::PhoneNumber.phone_number
      }
    end

    it "assigns expected territory" do
      expect { service.save }
        .to change(collectivity, :territory).to(epci)
    end

    it "assigns a commune using its code_insee" do
      commune = create(:commune)
      service = described_class.new(collectivity, {
        territory_type: "Commune",
        territory_code: commune.code_insee
      })

      expect { service.save }
        .to change(collectivity, :territory).to eq(commune)
    end

    it "assigns a departement using its code_departement" do
      departement = create(:departement)
      service = described_class.new(collectivity, {
        territory_type: "Departement",
        territory_code: departement.code_departement
      })

      expect { service.save }
        .to change(collectivity, :territory).to eq(departement)
    end

    it "assigns a region using its code_region" do
      region = create(:region)
      service = described_class.new(collectivity, {
        territory_type: "Region",
        territory_code: region.code_region
      })

      expect { service.save }
        .to change(collectivity, :territory).to eq(region)
    end

    it "returns a validation error on invalid code" do
      service = described_class.new(collectivity, {
        territory_type: "EPCI",
        territory_code: "12345689"
      })

      service.validate
      expect(service.errors).to include(:territory)
    end
  end
end
