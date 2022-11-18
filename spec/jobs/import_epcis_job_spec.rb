# frozen_string_literal: true

require "rails_helper"

RSpec.describe ImportEpcisJob do
  subject(:perform_now) { described_class.perform_now(url) }

  let(:url)     { "https://www.insee.fr/fr/statistiques/fichier/2510634/Intercommunalite_Metropole_au_01-01-2021.zip" }
  let(:fixture) { file_fixture("intercommunalites.zip") }

  before do
    stub_request(:head, url)
      .to_return(status: 200, body: "", headers: {})

    stub_request(:get, url)
      .to_return(status: 200, body: fixture)
  end

  it { expect { described_class.perform_later(url) }.not_to raise_error }

  it { expect { perform_now }.to change(EPCI, :count).by(2) }

  context "when perform completed" do
    before { perform_now }

    it { expect(EPCI.where(siren: "200000172", name: "CC Faucigny-Glières")).to be_exist }
    it { expect(EPCI.where(siren: "200023414", name: "Métropole Rouen Normandie")).to be_exist }
  end
end
