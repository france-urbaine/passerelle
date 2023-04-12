# frozen_string_literal: true

require "rails_helper"

RSpec.describe ImportCommunesJob do
  subject(:perform_now) { described_class.perform_now(url) }

  let(:url)     { "https://www.insee.fr/fr/statistiques/fichier/2028028/table-appartenance-geo-communes-21.zip" }
  let(:fixture) { file_fixture("communes.zip") }

  before do
    # Departements & epcis should exist for data integrity constraints
    create(:departement, code_departement: "01")
    create(:departement, code_departement: "13")
    create(:departement, code_departement: "29")
    create(:departement, code_departement: "976")
    create(:epci, siren: "200069193")
    create(:epci, siren: "240100883")
    create(:epci, siren: "200060465")
    create(:epci, siren: "200054807")

    stub_request(:head, url)
      .to_return(status: 200, body: "", headers: {})

    stub_request(:get, url)
      .to_return(status: 200, body: fixture)
  end

  it { expect { described_class.perform_later(url) }.not_to raise_error }

  it { expect { perform_now }.to change(Commune, :count).by(20) }

  context "when perform completed" do
    before { perform_now }

    it { expect(Commune.where(code_insee: "01001", code_departement: "01", siren_epci: "200069193", name: "L'Abergement-Clémenciat")).to be_exist }
    it { expect(Commune.where(code_insee: "01002", code_departement: "01", siren_epci: "240100883", name: "L'Abergement-de-Varey")).to be_exist }
    it { expect(Commune.where(code_insee: "29155", code_departement: "29", siren_epci: nil, name: "Ouessant")).to be_exist }
    it { expect(Commune.where(code_insee: "97601", code_departement: "976", siren_epci: "200060465", name: "Acoua")).to be_exist }
    it { expect(Commune.where(code_insee: ("13201".."13216")).count).to eq(16) }
  end
end
