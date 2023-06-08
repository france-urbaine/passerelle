# frozen_string_literal: true

require "rails_helper"

RSpec.describe "OfficeUsersController#destroy" do
  subject(:request) do
    delete "/guichets/#{office.id}/utilisateurs/#{user.id}", as:, headers:, params:
  end

  let(:as)      { |e| e.metadata[:as] }
  let(:headers) { |e| e.metadata[:headers] }
  let(:params)  { |e| e.metadata[:params] }

  let!(:ddfip)  { create(:ddfip) }
  let!(:office) { create(:office, ddfip: ddfip) }
  let!(:user)   { create(:user, organization: ddfip, offices: [office]) }

  describe "authorizations" do
    it_behaves_like "it requires authorization in HTML"
    it_behaves_like "it requires authorization in JSON"
    it_behaves_like "it responds with not acceptable in JSON when signed in"

    it_behaves_like "it denies access to DDFIP user"
    it_behaves_like "it denies access to DDFIP admin"
    it_behaves_like "it denies access to publisher user"
    it_behaves_like "it denies access to publisher admin"
    it_behaves_like "it denies access to collectivity user"
    it_behaves_like "it denies access to collectivity admin"
    it_behaves_like "it allows access to super admin"

    context "when the office is owned by the current user's DDFIP organization" do
      let(:ddfip) { current_user.organization }

      it_behaves_like "it denies access to DDFIP user"
      it_behaves_like "it allows access to DDFIP admin"
    end
  end

  describe "responses" do
    before { sign_in_as(:super_admin) }

    context "when the user is active" do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/guichets/#{office.id}") }

      it "removes the users from the office" do
        expect { request and office.users.reload }
          .to change(office, :user_ids).from([user.id]).to([])
      end

      it "doesn't discard the user" do
        expect { request and user.reload }
          .not_to change(user, :discarded_at).from(nil)
      end

      it "sets a flash notice" do
        expect(flash).to have_flash_notice.to eq(
          type:  "success",
          title: "L'utilisateur a été exclu du guichet.",
          delay: 10_000
        )
      end

      it "doens't set a flash action to cancel" do
        expect(flash).not_to have_flash_actions
      end
    end

    context "when the user doesn't belong to office" do
      let(:user) { create(:user, organization: ddfip) }

      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/guichets/#{office.id}") }
      it { expect { request and office.users.reload }.not_to change(office, :commune_ids) }
    end

    context "when the user doesn't belong to ddfip" do
      let(:user) { create(:user) }

      it { expect(response).to have_http_status(:not_found) }
      it { expect(response).to have_content_type(:html) }
      it { expect(response).to have_html_body }
    end

    context "when the user is discarded" do
      before { user.discard }

      it { expect(response).to have_http_status(:gone) }
      it { expect(response).to have_content_type(:html) }
      it { expect(response).to have_html_body }
    end

    context "when the user is missing" do
      before { user.destroy }

      it { expect(response).to have_http_status(:not_found) }
      it { expect(response).to have_content_type(:html) }
      it { expect(response).to have_html_body }
    end

    context "when the office is discarded" do
      before { office.discard }

      it { expect(response).to have_http_status(:gone) }
      it { expect(response).to have_content_type(:html) }
      it { expect(response).to have_html_body }
    end

    context "when the office is missing" do
      before { office.destroy }

      it { expect(response).to have_http_status(:not_found) }
      it { expect(response).to have_content_type(:html) }
      it { expect(response).to have_html_body }
    end

    context "when the DDFIP is discarded" do
      before { office.ddfip.discard }

      it { expect(response).to have_http_status(:gone) }
      it { expect(response).to have_content_type(:html) }
      it { expect(response).to have_html_body }
    end
  end
end
