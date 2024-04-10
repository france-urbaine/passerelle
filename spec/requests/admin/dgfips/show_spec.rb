# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin::DGFIPsController#show" do
  subject(:request) do
    get "/admin/dgfip", as:, headers:, params:
  end

  let(:as)      { |e| e.metadata[:as] }
  let(:headers) { |e| e.metadata[:headers] }
  let(:params)  { |e| e.metadata[:params] }

  before { DGFIP.find_or_create_singleton_record }

  describe "authorizations" do
    it_behaves_like "it requires to be signed in in HTML"
    it_behaves_like "it requires to be signed in in JSON"
    it_behaves_like "it responds with not acceptable in JSON when signed in"

    it_behaves_like "it denies access to publisher user"
    it_behaves_like "it denies access to publisher admin"
    it_behaves_like "it denies access to DGFIP user"
    it_behaves_like "it denies access to DGFIP admin"
    it_behaves_like "it denies access to collectivity user"
    it_behaves_like "it denies access to collectivity admin"

    it_behaves_like "it allows access to super admin"

    context "when the DGFIP is the current organization" do
      let(:dgfip) { current_user.organization }

      it_behaves_like "it denies access to DGFIP user"
      it_behaves_like "it denies access to DGFIP admin"
    end
  end

  describe "responses" do
    before { sign_in_as(:super_admin) }

    context "when the DGFIP is accessible" do
      it { expect(response).to have_http_status(:success) }
      it { expect(response).to have_media_type(:html) }
      it { expect(response).to have_html_body }
    end

    context "when the DGFIP is discarded" do
      before { DGFIP.discard_all }

      it { expect(response).to have_http_status(:success) }
      it { expect(response).to have_media_type(:html) }
      it { expect(response).to have_html_body }

      it "undiscards the DGFIP" do
        dgfip = DGFIP.last

        expect {
          request
          dgfip.reload
        }.to change(dgfip, :discarded_at).to(nil)
      end
    end

    context "when the DGFIP is missing" do
      before { DGFIP.destroy_all }

      it { expect(response).to have_http_status(:success) }
      it { expect(response).to have_media_type(:html) }
      it { expect(response).to have_html_body }

      it "creates a new default DGFIP" do
        expect { request }.to change(DGFIP, :count).by(1)
      end

      it "assigns default name" do
        request
        expect(DGFIP.last).to eq(DGFIP.find_or_create_singleton_record)
      end
    end
  end
end
