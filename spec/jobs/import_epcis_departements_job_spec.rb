# frozen_string_literal: true

require "rails_helper"

RSpec.describe ImportEPCIsDepartementsJob do
  subject { described_class.perform_now(url) }

  let(:url)     { "https://www.insee.fr/fr/statistiques/fichier/2510634/Intercommunalite_Metropole_au_01-01-2021.zip" }
  let(:fixture) { file_fixture("intercommunalites.zip") }

  before do
    # Departements should exist for data integrity constraints
    create(:departement, code_departement: "74")
    create(:departement, code_departement: "76")

    create(:epci, siren: "200000172", name: "CC Faucigny-Glières")
    create(:epci, siren: "200023414", name: "Métropole Rouen Normandie")

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

  it "updates EPCIs #code_departement" do
    expect { described_class.perform_now(url) }
      .to not_change(EPCI, :count)
      .and change { EPCI.find_by(siren: "200000172").code_departement }.to("74")
      .and change { EPCI.find_by(siren: "200023414").code_departement }.to("76")
  end
end
