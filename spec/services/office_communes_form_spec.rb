# frozen_string_literal: true

require "rails_helper"

RSpec.describe OfficeCommunesForm do
  subject(:form) do
    described_class.new(office)
  end

  let!(:office)      { create(:office) }
  let!(:departement) { office.ddfip.departement }

  describe "#model_name" do
    it { is_expected.to respond_to(:model_name) }
    it { expect(form.model_name.param_key).to eq("office_communes") }
  end

  describe "#commune_codes" do
    it "returns communes codes of all office's communes" do
      communes = create_list(:commune, 4)
      office.communes = communes[0..2]

      expect(form.commune_codes)
        .to be_an(Array)
        .and have(3).items
        .and include(communes[0].code_insee, communes[1].code_insee, communes[2].code_insee)
        .and exclude(communes[3].code_insee)
    end
  end

  describe "#epci_codes" do
    it "returns EPCI SIREN of EPCI having communes in the office" do
      epcis     = create_list(:epci, 3)
      communes  = create_list(:commune, 2, epci: epcis[0])
      communes += create_list(:commune, 2, epci: epcis[1])
      communes += create_list(:commune, 2, epci: epcis[2])

      office.communes = communes[0..2]

      expect(form.epci_codes)
        .to be_an(Array)
        .and have(2).items
        .and include(epcis[0].siren, epcis[1].siren)
        .and exclude(epcis[2].siren)
    end
  end

  describe "#suggested_communes" do
    it "returns a relation of communes belonging to the DDFIP departement" do
      communes  = create_list(:commune, 2, departement: departement)
      communes += create_list(:commune, 2)

      expect(form.suggested_communes)
        .to be_an(ActiveRecord::Relation)
        .and include(communes[0], communes[1])
        .and exclude(communes[2], communes[3])
    end
  end

  describe "#suggested_epcis" do
    it "returns a relation of EPCI having communes belonging to the DDFIP departement" do
      epcis = create_list(:epci, 4)

      create(:commune, departement: departement)
      create(:commune, departement: departement, epci: epcis[1])
      create(:commune, departement: departement, epci: epcis[2])
      create(:commune, epci: epcis[3])

      expect(form.suggested_epcis)
        .to be_an(ActiveRecord::Relation)
        .and include(epcis[1], epcis[2])
        .and exclude(epcis[0], epcis[3])
    end
  end
end
