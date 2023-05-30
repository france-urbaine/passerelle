# frozen_string_literal: true

require "rails_helper"

RSpec.describe "UsersController#undiscard_all" do
  subject(:request) do
    patch "/utilisateurs/undiscard", as:, headers:, params:
  end

  let(:as)      { |e| e.metadata[:as] }
  let(:headers) { |e| e.metadata[:headers] }
  let(:params)  { |e| e.metadata.fetch(:params, { ids: ids }) }

  let!(:users) do
    [
      create(:user, :discarded),
      create(:user, :discarded),
      create(:user, :discarded),
      create(:user)
    ]
  end

  let!(:ids) { users.take(2).map(&:id) }

  describe "authorizations" do
    it_behaves_like "it requires authorization in HTML"
    it_behaves_like "it requires authorization in JSON"
    it_behaves_like "it responds with not acceptable in JSON when signed in"

    it_behaves_like "it denies access to publisher user"
    it_behaves_like "it denies access to DDFIP user"
    it_behaves_like "it denies access to colletivity user"

    it_behaves_like "it allows access to publisher admin"
    it_behaves_like "it allows access to DDFIP admin"
    it_behaves_like "it allows access to colletivity admin"
    it_behaves_like "it allows access to super admin"
  end

  describe "responses" do
    context "when signed in as super admin" do
      before { sign_in_as(:super_admin) }

      context "with multiple ids" do
        it { expect(response).to have_http_status(:see_other) }
        it { expect(response).to redirect_to("/utilisateurs") }
        it { expect { request }.to change(User.discarded, :count).by(-2) }

        it "undiscards the selected users" do
          expect {
            request
            users.each(&:reload)
          }.to change(users[0], :discarded_at).to(nil)
            .and change(users[1], :discarded_at).to(nil)
            .and not_change(users[2], :discarded_at).from(be_present)
            .and not_change(users[3], :discarded_at).from(nil)
        end

        it "sets a flash notice" do
          expect(flash).to have_flash_notice.to eq(
            type:  "cancel",
            title: "La suppression des utilisateurs sélectionnés a été annulée.",
            delay: 3000
          )
        end
      end

      context "with `all` ids", params: { ids: "all" } do
        it { expect(response).to have_http_status(:see_other) }
        it { expect(response).to redirect_to("/utilisateurs") }
        it { expect(flash).to have_flash_notice }
        it { expect { request }.to change(User.discarded, :count).by(-3) }
      end

      context "with empty ids", params: { ids: [] } do
        it { expect(response).to have_http_status(:see_other) }
        it { expect(response).to redirect_to("/utilisateurs") }
        it { expect(flash).to have_flash_notice }
        it { expect { request }.not_to change(User.discarded, :count) }
      end

      context "with unknown ids", params: { ids: %w[1 2] } do
        it { expect(response).to have_http_status(:see_other) }
        it { expect(response).to redirect_to("/utilisateurs") }
        it { expect(flash).to have_flash_notice }
        it { expect { request }.not_to change(User.discarded, :count) }
      end

      context "with empty parameters", params: {} do
        it { expect(response).to have_http_status(:see_other) }
        it { expect(response).to redirect_to("/utilisateurs") }
        it { expect(flash).to have_flash_notice }
        it { expect { request }.not_to change(User.discarded, :count) }
      end

      context "with referrer header", headers: { "Referer" => "http://www.example.com/other/path" } do
        it { expect(response).to have_http_status(:see_other) }
        it { expect(response).to redirect_to("http://www.example.com/other/path") }
        it { expect(flash).to have_flash_notice }
      end

      context "with redirect parameter" do
        let(:params) { super().merge(redirect: "/other/path") }

        it { expect(response).to have_http_status(:see_other) }
        it { expect(response).to redirect_to("/other/path") }
        it { expect(flash).to have_flash_notice }
      end
    end

    context "when signed in as an organization admin" do
      let(:organization) { create(:publisher) }
      let(:users) do
        [
          create(:user, :discarded, organization: organization),
          create(:user, :discarded, organization: organization),
          create(:user, :discarded)
        ]
      end

      let(:ids) { users.map(&:id) }

      before { sign_in_as(:organization_admin, organization: organization) }

      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/utilisateurs") }
      it { expect { request }.to change(User.discarded, :count).by(-2) }

      it "undiscards only the selected users of the current organization" do
        expect {
          request
          users.each(&:reload)
        }.to change(users[0], :discarded_at).from(be_present)
          .and change(users[1], :discarded_at).from(be_present)
          .and not_change(users[2], :discarded_at).from(be_present)
      end
    end
  end
end
