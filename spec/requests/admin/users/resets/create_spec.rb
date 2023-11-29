# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin::Users::ResetsController#create" do
  subject(:request) do
    post "/admin/utilisateurs/#{user.id}/reset", as:, headers:, params:
  end

  let(:as)      { |e| e.metadata[:as] }
  let(:headers) { |e| e.metadata[:headers] }
  let(:params)  { |e| e.metadata[:params] }

  let!(:user) { create(:user) }

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

    context "when the user is the current user" do
      let(:user) { current_user }

      it_behaves_like "it denies access to super admin"
    end
  end

  describe "responses" do
    before { sign_in_as(:super_admin) }

    context "when user is confirmed" do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/admin/utilisateurs/#{user.id}") }

      it "updates confirmation token" do
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
      it { expect(response).to redirect_to("/admin/utilisateurs/#{user.id}") }

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
