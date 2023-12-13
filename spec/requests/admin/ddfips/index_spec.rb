# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin::DDFIPsController#index" do
  subject(:request) do
    get "/admin/ddfips", as:, headers:, params:, xhr:
  end

  let(:as)      { |e| e.metadata[:as] }
  let(:headers) { |e| e.metadata[:headers] }
  let(:params)  { |e| e.metadata[:params] }
  let(:xhr)     { |e| e.metadata[:xhr] }

  let!(:ddfips) do
    [
      create(:ddfip),
      create(:ddfip, :discarded),
      create(:ddfip)
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
  end

  describe "responses" do
    before { sign_in_as(:super_admin) }

    context "when requesting HTML" do
      it { expect(response).to have_http_status(:success) }
      it { expect(response).to have_content_type(:html) }
      it { expect(response).to have_html_body }

      it "returns only kept users" do
        aggregate_failures do
          expect(response).to have_html_body.to     have_text(ddfips[0].name)
          expect(response).to have_html_body.not_to have_text(ddfips[1].name)
          expect(response).to have_html_body.to     have_text(ddfips[2].name)
        end
      end
    end

    context "when requesting Turbo-Frame", :xhr, headers: { "Turbo-Frame" => "content" } do
      it { expect(response).to have_http_status(:success) }
      it { expect(response).to have_content_type(:html) }
      it { expect(response).to have_html_body.with_turbo_frame("content") }
    end

    context "when requesting autocompletion", :xhr, headers: { "Accept-Variant" => "autocomplete" } do
      let(:params) { { q: ddfips.first.name } }

      it { expect(response).to have_http_status(:success) }
      it { expect(response).to have_content_type(:html) }
      it { expect(response).to have_html_body.to have_selector("li", text: ddfips[0].name) }
    end
  end
end
