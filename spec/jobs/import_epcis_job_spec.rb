# frozen_string_literal: true

require "rails_helper"

RSpec.describe ImportEPCIsJob do
  subject { described_class.perform_now(url) }

  let(:url)     { "https://www.insee.fr/fr/statistiques/fichier/2510634/Intercommunalite_Metropole_au_01-01-2021.zip" }
  let(:fixture) { file_fixture("intercommunalites.zip") }

  before do
    stub_request(:head, url)
      .to_return(status: 200, body: "", headers: {})

    stub_request(:get, url)
      .to_return(status: 200, body: fixture)
  end

  it "enqueues a job without error" do
    expect { described_class.perform_later(url) }
      .to not_raise_error
      .and have_enqueued_job(described_class)
  end

  it "imports EPCIs" do
    aggregate_failures do
      expect { described_class.perform_now(url) }.to change(EPCI, :count).by(3)

      expect(EPCI.where(siren: "200000172", nature: "CC", name: "CC Faucigny-Glières")).to be_exist
      expect(EPCI.where(siren: "200023414", nature: "ME", name: "Métropole Rouen Normandie")).to be_exist
      expect(EPCI.where(siren: "200046977", nature: "ME", name: "Métropole de Lyon")).to be_exist
    end
  end
end
