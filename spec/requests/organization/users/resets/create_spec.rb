# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Organization::Users::ResetsController#create" do
  subject(:request) do
    post "/organisation/utilisateurs/#{user.id}/reset", as:, headers:, params:
  end

  let(:as)      { |e| e.metadata[:as] }
  let(:headers) { |e| e.metadata[:headers] }
  let(:params)  { |e| e.metadata[:params] }

  let!(:user)   { create(:user) }

  describe "authorizations" do
    it_behaves_like "it requires to be signed in in HTML"
    it_behaves_like "it requires to be signed in in JSON"
    it_behaves_like "it responds with not acceptable in JSON when signed in"

    it_behaves_like "it denies access to DDFIP user"
    it_behaves_like "it denies access to DDFIP super admin"
    it_behaves_like "it denies access to publisher user"
    it_behaves_like "it denies access to publisher super admin"
    it_behaves_like "it denies access to collectivity user"
    it_behaves_like "it denies access to collectivity super admin"

    it_behaves_like "it responds with not found to DDFIP admin"
    it_behaves_like "it responds with not found to DDFIP supervisor"
    it_behaves_like "it responds with not found to publisher admin"
    it_behaves_like "it responds with not found to collectivity admin"

    context "when user organization is the current organization" do
      let(:user) { create(:user, organization: current_user.organization) }

      it_behaves_like "it denies access to DDFIP user"
      it_behaves_like "it denies access to DDFIP supervisor"
      it_behaves_like "it denies access to publisher user"
      it_behaves_like "it denies access to collectivity user"

      it_behaves_like "it allows access to DDFIP admin"
      it_behaves_like "it allows access to publisher admin"
      it_behaves_like "it allows access to collectivity admin"
    end

    context "when user is member of a collectivity owned by current organization" do
      let(:collectivity) { create(:collectivity, publisher: current_user.organization) }
      let(:user)         { create(:user, organization: collectivity) }

      it_behaves_like "it responds with not found to publisher admin"
    end

    context "when user is member of a supervised office" do
      let(:user) { create(:user, offices: [current_user.offices.first], organization: current_user.organization) }

      it_behaves_like "it allows access to DDFIP supervisor"
    end

    context "when the user is the current user" do
      let(:user) { current_user }

      it_behaves_like "it denies access to DDFIP admin"
      it_behaves_like "it denies access to DDFIP supervisor"
      it_behaves_like "it denies access to publisher admin"
      it_behaves_like "it denies access to collectivity admin"
    end
  end

  describe "responses" do
    before { sign_in_as(:organization_admin, organization: user.organization) }

    context "when user is confirmed" do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/organisation/utilisateurs/#{user.id}") }

      it "updates its confirmation token" do
        expect { request and user.reload }
          .to  change(user, :confirmed_at).to(nil)
          .and change(user, :confirmation_token)
          .and change(user, :confirmation_sent_at)
      end

      it "sets a flash notice" do
        expect(flash).to have_flash_notice.to eq(
          scheme: "success",
          header: "L'invitation a été envoyée.",
          delay:  3000
        )
      end

      it "delivers confirmation instructions" do
        expect { request }
          .to have_sent_emails.by(1)
          .and have_sent_email.with_subject("Votre inscription sur Passerelle")
      end
    end

    context "when user is not confirmed (yet or after being resetted)" do
      let(:user) { create(:user, :unconfirmed) }

      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/organisation/utilisateurs/#{user.id}") }

      it "updates its confirmation token" do
        expect { request and user.reload }
          .to  not_change(user, :confirmed_at).from(nil)
          .and change(user, :confirmation_token)
          .and change(user, :confirmation_sent_at)
      end

      it "sets a flash notice" do
        expect(flash).to have_flash_notice.to eq(
          scheme: "success",
          header: "L'invitation a été envoyée.",
          delay:  3000
        )
      end

      it "delivers confirmation instructions" do
        expect { request }
          .to have_sent_emails.by(1)
          .and have_sent_email.with_subject("Votre inscription sur Passerelle")
      end
    end
  end
end
