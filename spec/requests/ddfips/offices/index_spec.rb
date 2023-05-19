# frozen_string_literal: true

require "rails_helper"

RSpec.describe "DDFIPs::CollectivitiesController#index" do
  subject(:request) do
    get "/ddfips/#{ddfip.id}/guichets", as:, headers:, params:, xhr:
  end

  let(:as)      { |e| e.metadata[:as] }
  let(:headers) { |e| e.metadata[:headers] }
  let(:params)  { |e| e.metadata[:params] }
  let(:xhr)     { |e| e.metadata[:xhr] }

  let!(:ddfip) { create(:ddfip) }
  let!(:offices) do
    [
      create(:office),
      create(:office, ddfip: ddfip),
      create(:office, :discarded, ddfip: ddfip),
      create(:office, ddfip: ddfip)
    ]
  end

  it_behaves_like "it requires authorization in HTML"
  it_behaves_like "it requires authorization in JSON"
  it_behaves_like "it doesn't accept JSON when signed in"
  it_behaves_like "it allows access to publisher user"
  it_behaves_like "it allows access to publisher admin"
  it_behaves_like "it allows access to DDFIP user"
  it_behaves_like "it allows access to DDFIP admin"
  it_behaves_like "it allows access to colletivity user"
  it_behaves_like "it allows access to colletivity admin"
  it_behaves_like "it allows access to super admin"

  context "when signed in" do
    before { sign_in_as(:publisher, :organization_admin) }

    context "when requesting HTML" do
      context "when the DDFIP is accessible" do
        it { expect(response).to have_http_status(:see_other) }
        it { expect(response).to redirect_to("/ddfips/#{ddfip.id}") }
      end

      context "when the DDFIP is discarded" do
        before { ddfip.discard }

        it { expect(response).to have_http_status(:gone) }
        it { expect(response).to have_content_type(:html) }
        it { expect(response).to have_html_body }
      end

      context "when the DDFIP is missing" do
        before { ddfip.destroy }

        it { expect(response).to have_http_status(:not_found) }
        it { expect(response).to have_content_type(:html) }
        it { expect(response).to have_html_body }
      end
    end

    context "when requesting Turbo-Frame", headers: { "Turbo-Frame" => "datatable-officess" }, xhr: true do
      context "when the DDFIP is accessible" do
        it { expect(response).to have_http_status(:success) }
        it { expect(response).to have_content_type(:html) }
        it { expect(response).to have_html_body.with_turbo_frame("datatable-offices") }

        it "returns only kept offices on the DDFIP" do
          aggregate_failures do
            expect(response.parsed_body).to not_include(CGI.escape_html(offices[0].name))
            expect(response.parsed_body).to include(CGI.escape_html(offices[1].name))
            expect(response.parsed_body).to not_include(CGI.escape_html(offices[2].name))
            expect(response.parsed_body).to include(CGI.escape_html(offices[3].name))
          end
        end
      end

      context "when the DDFIP is discarded" do
        before { ddfip.discard }

        it { expect(response).to have_http_status(:gone) }
        it { expect(response).to have_content_type(:html) }
        it { expect(response).to have_html_body }
      end

      context "when the DDFIP is missing" do
        before { ddfip.destroy }

        it { expect(response).to have_http_status(:not_found) }
        it { expect(response).to have_content_type(:html) }
        it { expect(response).to have_html_body }
      end
    end

    context "when requesting autocompletion", headers: { "Accept-Variant" => "autocomplete" }, xhr: true do
      it { expect(response).to have_http_status(:not_implemented) }
      it { expect(response).to have_content_type(:html) }
      it { expect(response).to have_html_body }
    end
  end
end
