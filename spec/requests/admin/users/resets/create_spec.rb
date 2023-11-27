# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin::Users::ResetsController#create" do
  subject(:request) do
    post "/admin/utilisateurs/#{user.id}/reset", as:, headers:, params:
  end

  let(:as)      { |e| e.metadata[:as] }
  let(:headers) { |e| e.metadata[:headers] }
  let(:params)  { |e| e.metadata[:params] }

  let!(:user) do
    Timecop.freeze(1.month.ago) do
      create(:user, :invited)
    end
  end

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
  end

  describe "responses" do
    before { sign_in_as(:super_admin) }

    context "when user is confirmed" do
      let(:user) do
        create(:user, :invited)
      end

      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/admin/utilisateurs/#{user.id}") }

      it "updates confirmation token" do
        expect { request and user.reload }
          .to  change(user, :confirmation_token)
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

    context "when user is unconfirmed" do
      let(:user) do
        create(:user, :invited, :unconfirmed)
      end

      it { expect(response).to have_http_status(:forbidden) }

      it "doesn't update the user" do
        expect { request and user.reload }
          .not_to change(user, :updated_at)
      end

      it "doesn't sets a flash notice" do
        expect(flash).not_to have_flash_notice
      end

      it "doenst' enqueues any job to deliver notification" do
        expect { request }.not_to have_enqueued_job
      end
    end
  end
end
