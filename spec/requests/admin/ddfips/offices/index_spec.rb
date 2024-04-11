# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin::DDFIPs::OfficesController#index" do
  subject(:request) do
    get "/admin/ddfips/#{ddfip.id}/guichets", as:, headers:, params:, xhr:
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

    context "when the DDFIP is the current organization" do
      let(:ddfip) { current_user.organization }

      it_behaves_like "it denies access to DDFIP user"
      it_behaves_like "it denies access to DDFIP admin"
    end
  end

  describe "responses" do
    before { sign_in_as(:super_admin) }

    context "when requesting HTML" do
      context "when the DDFIP is accessible" do
        it { expect(response).to have_http_status(:see_other) }
        it { expect(response).to redirect_to("/admin/ddfips/#{ddfip.id}") }
      end

      context "when the DDFIP is discarded" do
        before { ddfip.discard }

        it { expect(response).to have_http_status(:gone) }
        it { expect(response).to have_media_type(:html) }
        it { expect(response).to have_html_body.to have_text("Cette DDFIP est en cours de suppression.") }
      end

      context "when the DDFIP is missing" do
        before { ddfip.destroy }

        it { expect(response).to have_http_status(:not_found) }
        it { expect(response).to have_media_type(:html) }
        it { expect(response).to have_html_body.to have_text("Cette DDFIP n'a pas été trouvée ou n'existe plus.") }
      end
    end

    context "when requesting Turbo-Frame", :xhr, headers: { "Turbo-Frame" => "datatable-officess" } do
      context "when the DDFIP is accessible" do
        it { expect(response).to have_http_status(:success) }
        it { expect(response).to have_media_type(:html) }
        it { expect(response).to have_html_body.with_turbo_frame("datatable-offices") }

        it "returns only kept offices on the DDFIP" do
          aggregate_failures do
            expect(response).to have_html_body.to have_no_text(offices[0].name)
            expect(response).to have_html_body.to have_text(offices[1].name)
            expect(response).to have_html_body.to have_no_text(offices[2].name)
            expect(response).to have_html_body.to have_text(offices[3].name)
          end
        end
      end

      context "when the DDFIP is discarded" do
        before { ddfip.discard }

        it { expect(response).to have_http_status(:gone) }
        it { expect(response).to have_media_type(:html) }
        it { expect(response).to have_html_body.to have_text("Cette DDFIP est en cours de suppression.") }
      end

      context "when the DDFIP is missing" do
        before { ddfip.destroy }

        it { expect(response).to have_http_status(:not_found) }
        it { expect(response).to have_media_type(:html) }
        it { expect(response).to have_html_body.to have_text("Cette DDFIP n'a pas été trouvée ou n'existe plus.") }
      end
    end

    context "when requesting autocompletion", :xhr, headers: { "Accept-Variant" => "autocomplete" } do
      it { expect(response).to have_http_status(:not_implemented) }
      it { expect(response).to have_media_type(:html) }
      it { expect(response).to have_html_body }
    end
  end
end
