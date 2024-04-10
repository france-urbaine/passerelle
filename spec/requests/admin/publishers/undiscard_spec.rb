# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin::PublishersController#undiscard" do
  subject(:request) do
    patch "/admin/editeurs/#{publisher.id}/undiscard", as:, headers:, params:
  end

  let(:as)      { |e| e.metadata[:as] }
  let(:headers) { |e| e.metadata[:headers] }
  let(:params)  { |e| e.metadata[:params] }

  let!(:publisher) { create(:publisher, :discarded) }

  describe "authorizations" do
    it_behaves_like "it requires to be signed in in HTML"
    it_behaves_like "it requires to be signed in in JSON"
    it_behaves_like "it responds with not acceptable in JSON when signed in"

    it_behaves_like "it denies access to DDFIP user"
    it_behaves_like "it denies access to DDFIP admin"
    it_behaves_like "it denies access to publisher user"
    it_behaves_like "it denies access to publisher admin"
    it_behaves_like "it denies access to collectivity user"
    it_behaves_like "it denies access to collectivity admin"

    it_behaves_like "it allows access to super admin"

    context "when the publisher is the current organization" do
      let(:publisher) { current_user.organization }

      it_behaves_like "it denies access to publisher user"
      it_behaves_like "it denies access to publisher admin"
    end
  end

  describe "responses" do
    before { sign_in_as(:super_admin) }

    context "when the publisher is discarded" do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/admin/editeurs") }
      it { expect { request }.to change(Publisher.discarded, :count).by(-1) }

      it "undiscards the publisher" do
        expect { request and publisher.reload }
          .to change(publisher, :discarded_at).to(nil)
      end

      it "sets a flash notice" do
        expect(flash).to have_flash_notice.to eq(
          scheme: "done",
          icon:   "arrow-path",
          header: "La suppression de l'éditeur a été annulée.",
          delay:  3000
        )
      end
    end

    context "when the publisher is not discarded" do
      before { publisher.undiscard }

      it { expect(response).to have_http_status(:see_other) }
      it { expect { request and publisher.reload }.not_to change(publisher, :discarded_at).from(nil) }
    end

    context "when the publisher is missing" do
      before { publisher.destroy }

      it { expect(response).to have_http_status(:not_found) }
      it { expect(response).to have_media_type(:html) }
      it { expect(response).to have_html_body }
    end

    context "with referrer header", headers: { "Referer" => "http://example.com/other/path" } do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("http://example.com/other/path") }
      it { expect(flash).to have_flash_notice }
    end

    context "with redirect parameter", params: { redirect: "/other/path" } do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/other/path") }
      it { expect(flash).to have_flash_notice }
    end
  end
end
