# frozen_string_literal: true

require "rails_helper"

RSpec.describe TerritoriesUpdate do
  before do
    stub_request(:head, "https://www.insee.fr/valid/path/to/file.zip")
      .to_return(status: 200, body: "", headers: {})

    stub_request(:head, "https://www.insee.fr/unknown/path/to/file.zip")
      .to_return(status: 404, body: "", headers: {})
  end

  it { is_expected.to validate_presence_of(:communes_url) }
  it { is_expected.to validate_presence_of(:epcis_url) }

  it { is_expected.to allow_value("https://www.insee.fr/valid/path/to/file.zip").for(:communes_url) }
  it { is_expected.to allow_value("https://www.insee.fr/valid/path/to/file.zip").for(:epcis_url) }

  it { is_expected.to allow_value("valid/path/to/file.zip").for(:communes_url) }
  it { is_expected.to allow_value("valid/path/to/file.zip").for(:epcis_url) }

  it { is_expected.not_to allow_value("https://www.insee.fr/unknown/path/to/file").for(:communes_url) }
  it { is_expected.not_to allow_value("https://www.insee.fr/unknown/path/to/file.zip").for(:communes_url) }
  it { is_expected.not_to allow_value("ftp://www.insee.fr/unknown/path/to/file.zip").for(:communes_url) }

  describe "#format_urls" do
    subject(:model) do
      described_class.new(
        communes_url: "path/communes.zip",
        epcis_url:   "path/epcis.zip"
      )
    end

    it { expect { model.format_urls }.to change(model, :communes_url).to("https://www.insee.fr/path/communes.zip") }
    it { expect { model.format_urls }.to change(model, :epcis_url)   .to("https://www.insee.fr/path/epcis.zip") }
  end

  describe "#strip_domain_urls" do
    subject(:model) do
      described_class.new(
        communes_url: "https://www.insee.fr/path/communes.zip",
        epcis_url:    "https://www.insee.fr/path/epcis.zip"
      )
    end

    it { expect { model.strip_domain_urls }.to change(model, :communes_url).to("path/communes.zip") }
    it { expect { model.strip_domain_urls }.to change(model, :epcis_url)   .to("path/epcis.zip") }
  end

  describe "#perform_later" do
    subject(:model) do
      described_class.new(
        communes_url: "https://www.insee.fr/path/communes.zip",
        epcis_url:    "https://www.insee.fr/path/epcis.zip"
      )
    end

    it { expect { model.perform_later }.to have_enqueued_job(ImportCommunesJob).with("https://www.insee.fr/path/communes.zip") }
    it { expect { model.perform_later }.to have_enqueued_job(ImportEPCIsJob).with("https://www.insee.fr/path/epcis.zip") }
  end
end
