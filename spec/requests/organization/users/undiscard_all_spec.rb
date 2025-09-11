# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Organization::UsersController#undiscard_all" do
  subject(:request) do
    patch "/organisation/utilisateurs/undiscard", as:, headers:, params:
  end

  let(:as)      { |e| e.metadata[:as] }
  let(:headers) { |e| e.metadata[:headers] }
  let(:params)  { |e| e.metadata.fetch(:params, { ids: ids }) }

  let!(:organization) { create(%i[publisher ddfip collectivity].sample) }
  let!(:users) do
    [
      create(:user, :discarded, organization: organization),
      create(:user, :discarded, organization: organization),
      create(:user, :discarded),
      create(:user, :discarded, organization: organization),
      create(:user, organization: organization)
    ]
  end

  let!(:ids) { users.take(3).map(&:id) }

  describe "authorizations" do
    it_behaves_like "it requires to be signed in in HTML"
    it_behaves_like "it requires to be signed in in JSON"
    it_behaves_like "it responds with not acceptable in JSON when signed in"

    it_behaves_like "it denies access to super admin"
    it_behaves_like "it denies access to DDFIP user"
    it_behaves_like "it denies access to DDFIP supervisor"
    it_behaves_like "it denies access to publisher user"
    it_behaves_like "it denies access to collectivity user"

    it_behaves_like "it allows access to DDFIP admin"
    it_behaves_like "it allows access to publisher admin"
    it_behaves_like "it allows access to collectivity admin"
  end

  describe "responses" do
    before { sign_in_as(:organization_admin, organization: organization) }

    context "with multiple ids" do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/organisation/utilisateurs") }
      it { expect { request }.to change(User.discarded, :count).by(-2) }

      it "undiscards the selected users" do
        expect {
          request
          users.each(&:reload)
        }.to   change(users[0], :discarded_at).to(nil)
          .and change(users[1], :discarded_at).to(nil)
          .and not_change(users[2], :discarded_at).from(be_present)
          .and not_change(users[3], :discarded_at).from(be_present)
          .and not_change(users[4], :discarded_at).from(nil)
      end

      it "sets a flash notice" do
        expect(flash).to have_flash_notice.to eq(
          scheme: "done",
          icon:   "arrow-path",
          header: "La suppression des utilisateurs sélectionnés a été annulée.",
          delay:  3000
        )
      end
    end

    context "with `all` ids", params: { ids: "all" } do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/organisation/utilisateurs") }
      it { expect(flash).to have_flash_notice }
      it { expect { request }.to change(User.discarded, :count).by(-3) }
    end

    context "with empty ids", params: { ids: [] } do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/organisation/utilisateurs") }
      it { expect(flash).to have_flash_notice }
      it { expect { request }.not_to change(User.discarded, :count) }
    end

    context "with unknown ids", params: { ids: %w[1 2] } do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/organisation/utilisateurs") }
      it { expect(flash).to have_flash_notice }
      it { expect { request }.not_to change(User.discarded, :count) }
    end

    context "with empty parameters", params: {} do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/organisation/utilisateurs") }
      it { expect(flash).to have_flash_notice }
      it { expect { request }.not_to change(User.discarded, :count) }
    end

    context "with referrer header", headers: { "Referer" => "http://example.com/other/path" } do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("http://example.com/other/path") }
      it { expect(flash).to have_flash_notice }
    end

    context "with redirect parameter" do
      let(:params) { super().merge(redirect: "/other/path") }

      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/other/path") }
      it { expect(flash).to have_flash_notice }
    end
  end
end
