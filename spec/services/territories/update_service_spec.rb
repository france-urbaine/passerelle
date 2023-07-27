# frozen_string_literal: true

require "rails_helper"

RSpec.describe Territories::UpdateService do
  include Shoulda::Matchers::ActiveModel
  include Shoulda::Matchers::ActiveRecord

  before do
    stub_request(:head, "https://www.insee.fr/path/communes.zip").to_return(status: 200, body: "", headers: {})
    stub_request(:head, "https://www.insee.fr/path/epcis.zip").to_return(status: 200, body: "", headers: {})
    stub_request(:head, "https://www.insee.fr/unknown/path/to/file.zip").to_return(status: 404, body: "", headers: {})

    allow(ImportCommunesJob).to receive(:perform_now)
    allow(ImportEPCIsJob).to receive(:perform_now)
  end

  it { is_expected.to validate_presence_of(:communes_url) }
  it { is_expected.to validate_presence_of(:epcis_url) }

  it { is_expected.to allow_value("https://www.insee.fr/path/communes.zip").for(:communes_url) }
  it { is_expected.to allow_value("https://www.insee.fr/path/epcis.zip").for(:epcis_url) }

  it { is_expected.to allow_value("path/communes.zip").for(:communes_url) }
  it { is_expected.to allow_value("path/epcis.zip").for(:epcis_url) }

  it { is_expected.not_to allow_value("https://www.insee.fr/unknown/path/to/file").for(:communes_url) }
  it { is_expected.not_to allow_value("https://www.insee.fr/unknown/path/to/file.zip").for(:communes_url) }
  it { is_expected.not_to allow_value("ftp://www.insee.fr/unknown/path/to/file.zip").for(:communes_url) }

  describe "#perform_later" do
    context "with valid URLs" do
      subject(:service) do
        described_class.new(
          communes_url: "https://www.insee.fr/path/communes.zip",
          epcis_url:    "https://www.insee.fr/path/epcis.zip"
        )
      end

      it "returns a successful result" do
        expect(service.perform_later).to be_successful
      end

      it "enqueues jobs to import data" do
        expect { service.perform_later }
          .to have_enqueued_job(ImportCommunesJob).with("https://www.insee.fr/path/communes.zip")
          .and have_enqueued_job(ImportEPCIsJob).with("https://www.insee.fr/path/epcis.zip")
      end
    end

    context "with stripped but valid paths" do
      subject(:service) do
        described_class.new(
          communes_url: "path/communes.zip",
          epcis_url:    "path/epcis.zip"
        )
      end

      it "returns a successful result" do
        expect(service.perform_later).to be_successful
      end

      it "enqueues jobs to import data" do
        expect { service.perform_later }
          .to have_enqueued_job(ImportCommunesJob).with("https://www.insee.fr/path/communes.zip")
          .and have_enqueued_job(ImportEPCIsJob).with("https://www.insee.fr/path/epcis.zip")
      end
    end

    context "with invalid URLs" do
      subject(:service) do
        described_class.new(
          communes_url: "unknown/path/to/file.zip",
          epcis_url:    "unknown/path/to/file.zip"
        )
      end

      it "returns a successful result" do
        expect(service.perform_later).to be_failed
      end

      it "doesn't enqueue jobs" do
        expect { service.perform_later }
          .to not_have_enqueued_job(ImportCommunesJob)
          .and not_have_enqueued_job(ImportCommunesJob)
      end
    end
  end

  describe "#perform_now" do
    context "with valid URLs" do
      subject(:service) do
        described_class.new(
          communes_url: "https://www.insee.fr/path/communes.zip",
          epcis_url:    "https://www.insee.fr/path/epcis.zip"
        )
      end

      it "returns a successful result" do
        expect(service.perform_now).to be_successful
      end

      it "calls jobs to import data" do
        expect { service.perform_now }
          .to send_message(ImportCommunesJob, :perform_now).with("https://www.insee.fr/path/communes.zip")
          .and send_message(ImportEPCIsJob, :perform_now).with("https://www.insee.fr/path/epcis.zip")
      end
    end

    context "with stripped but valid paths" do
      subject(:service) do
        described_class.new(
          communes_url: "path/communes.zip",
          epcis_url:    "path/epcis.zip"
        )
      end

      it "returns a successful result" do
        expect(service.perform_now).to be_successful
      end

      it "calls jobs to import data" do
        expect { service.perform_now }
          .to send_message(ImportCommunesJob, :perform_now).with("https://www.insee.fr/path/communes.zip")
          .and send_message(ImportEPCIsJob, :perform_now).with("https://www.insee.fr/path/epcis.zip")
      end
    end

    context "with invalid URLs" do
      subject(:service) do
        described_class.new(
          communes_url: "unknown/path/to/file.zip",
          epcis_url:    "unknown/path/to/file.zip"
        )
      end

      it "returns a successful result" do
        expect(service.perform_now).to be_failed
      end

      it "doesn't enqueue jobs" do
        expect { service.perform_now }
          .to not_send_message(ImportCommunesJob, :perform_now)
          .and not_send_message(ImportCommunesJob, :perform_now)
      end
    end
  end
end
