# frozen_string_literal: true

require "rails_helper"

RSpec.describe "TerritoriesController#update" do
  subject(:request) do
    patch "/territoires", as:, headers:, params:
  end

  let(:as)      { |e| e.metadata[:as] }
  let(:headers) { |e| e.metadata[:headers] }
  let(:params)  { |e| e.metadata.fetch(:params, { territories_update: attributes }) }

  let(:attributes) { { communes_url: url, epcis_url: url } }
  let(:url)        { "https://www.insee.fr/valid/path/to/file.zip" }

  before do
    stub_request(:head, "https://www.insee.fr/valid/path/to/file.zip")
      .to_return(status: 200, body: "", headers: {})
  end

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

  context "when signed in as super admin" do
    before { sign_in_as(:super_admin) }

    context "with valid attributes" do
      it { expect(response).to have_http_status(:found) }
      it { expect(response).to redirect_to("/communes") }

      it "is expected to enqueue jobs" do
        expect {
          request
        } .to  have_enqueued_job(ImportCommunesJob).with(url)
          .and have_enqueued_job(ImportEPCIsJob).with(url)
      end
    end

    context "with invalid attributes" do
      let(:attributes) { { communes_url: "", epcis_url: "" } }

      it { expect(response).to have_http_status(:unprocessable_entity) }
      it { expect(response).to have_content_type(:html) }
      it { expect(response).to have_html_body }

      it "is expected to not enqueue any jobs" do
        expect { request }.not_to have_enqueued_job
      end
    end
  end
end
