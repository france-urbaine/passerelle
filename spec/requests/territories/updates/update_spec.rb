# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Territories::TerritoriesController#update" do
  subject(:request) do
    patch "/territoires/mise-a-jour", as:, headers:, params:
  end

  let(:as)      { |e| e.metadata[:as] }
  let(:headers) { |e| e.metadata[:headers] }
  let(:params)  { |e| e.metadata.fetch(:params, attributes) }

  let(:attributes) do
    {
      communes_url: "valid/path/to/communes.zip",
      epcis_url:    "valid/path/to/epcis.zip"
    }
  end

  before do
    stub_request(:head, "https://www.insee.fr/valid/path/to/communes.zip").to_return(status: 200, body: "", headers: {})
    stub_request(:head, "https://www.insee.fr/valid/path/to/epcis.zip").to_return(status: 200, body: "", headers: {})
  end

  describe "authorizations" do
    it_behaves_like "it requires to be signed in in HTML"
    it_behaves_like "it requires to be signed in in JSON"
    it_behaves_like "it responds with not acceptable in JSON when signed in"

    it_behaves_like "it denies access to publisher user"
    it_behaves_like "it denies access to publisher admin"
    it_behaves_like "it denies access to DDFIP user"
    it_behaves_like "it denies access to DDFIP admin"
    it_behaves_like "it denies access to collectivity user"
    it_behaves_like "it denies access to collectivity admin"

    it_behaves_like "it allows access to super admin"
  end

  describe "responses" do
    before { sign_in_as(:super_admin) }

    context "with valid attributes" do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/territoires/communes") }

      it "enqueues some jobs to import data from URL" do
        expect {
          request
        } .to  have_enqueued_job(ImportCommunesJob).with("https://www.insee.fr/valid/path/to/communes.zip")
          .and have_enqueued_job(ImportEPCIsJob).with("https://www.insee.fr/valid/path/to/epcis.zip")
      end

      it "sets a flash notice" do
        expect(flash).to have_flash_notice.to eq(
          scheme: "success",
          header: "La mise à jour a été lancée en arrière-plan.",
          body:   "Les données seront disponibles dans quelques minutes.",
          delay:  3000
        )
      end
    end

    context "with invalid attributes" do
      let(:attributes) { { communes_url: "", epcis_url: "" } }

      it { expect(response).to have_http_status(:unprocessable_content) }
      it { expect(response).to have_media_type(:html) }
      it { expect(response).to have_html_body }

      it "is expected to not enqueue any jobs" do
        expect { request }.not_to have_enqueued_job
      end
    end
  end
end
