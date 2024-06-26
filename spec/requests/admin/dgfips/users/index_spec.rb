# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin::DGFIPs::UsersController#index" do
  subject(:request) do
    get "/admin/dgfip/utilisateurs", as:, headers:, params:, xhr:
  end

  let(:as)      { |e| e.metadata[:as] }
  let(:headers) { |e| e.metadata[:headers] }
  let(:params)  { |e| e.metadata[:params] }
  let(:xhr)     { |e| e.metadata[:xhr] }

  let!(:dgfip) { DGFIP.kept.first || create(:dgfip) }
  let!(:users) do
    [
      create(:user, :discarded, organization: dgfip),
      create(:user, :discarded),
      create(:user),
      create(:user, organization: dgfip)
    ]
  end

  describe "authorizations" do
    it_behaves_like "it requires to be signed in in HTML"
    it_behaves_like "it requires to be signed in in JSON"
    it_behaves_like "it responds with not acceptable in JSON when signed in"

    it_behaves_like "it denies access to DGFIP user"
    it_behaves_like "it denies access to DGFIP admin"
    it_behaves_like "it denies access to publisher user"
    it_behaves_like "it denies access to publisher admin"
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

    context "when requesting HTML" do
      context "when the DGFIP is accesible" do
        it { expect(response).to have_http_status(:see_other) }
        it { expect(response).to redirect_to("/admin/dgfip") }
      end

      context "when the DGFIP is discarded" do
        before { DGFIP.discard_all }

        it { expect(response).to have_http_status(:see_other) }
        it { expect(response).to redirect_to("/admin/dgfip") }
      end

      context "when the DGFIP is missing" do
        before { dgfip.destroy }

        it { expect(response).to have_http_status(:see_other) }
        it { expect(response).to redirect_to("/admin/dgfip") }
      end
    end

    context "when requesting Turbo-Frame", :xhr, headers: { "Turbo-Frame" => "datatable-users" } do
      context "when the DGFIP is accesible" do
        it { expect(response).to have_http_status(:success) }
        it { expect(response).to have_media_type(:html) }
        it { expect(response).to have_html_body.with_turbo_frame("datatable-users") }

        it "returns only kept members of the organization" do
          aggregate_failures do
            expect(response).to have_html_body.to have_no_text(users[0].name)
            expect(response).to have_html_body.to have_no_text(users[1].name)
            expect(response).to have_html_body.to have_no_text(users[2].name)
            expect(response).to have_html_body.to have_text(users[3].name)
          end
        end
      end

      context "when the DGFIP is discarded" do
        before { dgfip.discard }

        it { expect(response).to have_http_status(:success) }
        it { expect(response).to have_media_type(:html) }
        it { expect(response).to have_html_body.with_turbo_frame("datatable-users") }
      end

      context "when the DGFIP is missing" do
        before { dgfip.destroy }

        it { expect(response).to have_http_status(:success) }
        it { expect(response).to have_media_type(:html) }
        it { expect(response).to have_html_body.with_turbo_frame("datatable-users") }
      end
    end

    context "when requesting autocompletion", :xhr, headers: { "Accept-Variant" => "autocomplete" } do
      it { expect(response).to have_http_status(:not_implemented) }
      it { expect(response).to have_media_type(:html) }
      it { expect(response).to have_html_body }
    end
  end
end
