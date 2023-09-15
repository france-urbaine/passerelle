# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Organization::Users::InvitationsController#create" do
  subject(:request) do
    post "/organisation/utilisateurs/#{user.id}/invitation", as:, headers:, params:
  end

  let(:as)      { |e| e.metadata[:as] }
  let(:headers) { |e| e.metadata[:headers] }
  let(:params)  { |e| e.metadata[:params] }

  let!(:user) do
    Timecop.freeze(1.month.ago) do
      create(:user, :invited, :unconfirmed)
    end
  end

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
    it_behaves_like "it responds with not found to publisher admin"
    it_behaves_like "it responds with not found to collectivity admin"

    context "when user organization is the current organization" do
      let(:user) { create(:user, organization: current_user.organization) }

      it_behaves_like "it denies access to DDFIP user"
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
  end

  describe "responses" do
    before { sign_in_as(:organization_admin, organization: user.organization) }

    context "when user's invitation expired" do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/organisation/utilisateurs/#{user.id}") }

      it "updates its confirmation token" do
        expect { request and user.reload }
          .to  change(user, :confirmation_token)
          .and change(user, :confirmation_sent_at)
      end

      it "sets a flash notice" do
        expect(flash).to have_flash_notice.to eq(
          type:  "success",
          title: "L'invitation a été envoyée.",
          delay: 3000
        )
      end

      it "enqueues a job to deliver notification" do
        expect { request }
          .to have_enqueued_job.once
          .and have_enqueued_job(ActionMailer::MailDeliveryJob)
      end

      it "sent instructions to confirm" do
        expect { request && perform_enqueued_jobs }
          .to have_sent_emails.by(1)
          .and have_sent_email.with_subject("Votre inscription sur FiscaHub")
      end
    end

    context "when user's invitation is still valid" do
      let(:user) do
        create(:user, :invited, :unconfirmed)
      end

      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/organisation/utilisateurs/#{user.id}") }

      it "doesn't update confirmation token" do
        expect { request and user.reload }
          .to  not_change(user, :confirmation_token)
          .and not_change(user, :confirmation_sent_at)
      end

      it "sets a flash notice" do
        expect(flash).to have_flash_notice.to eq(
          type:  "success",
          title: "L'invitation a été envoyée.",
          delay: 3000
        )
      end

      it "enqueues a job to deliver notification" do
        expect { request }
          .to have_enqueued_job.once
          .and have_enqueued_job(ActionMailer::MailDeliveryJob)
      end

      it "sent instructions to confirm" do
        expect { request && perform_enqueued_jobs }
          .to have_sent_emails.by(1)
          .and have_sent_email.with_subject("Votre inscription sur FiscaHub")
      end
    end

    context "when user is already confirmed" do
      let(:user) do
        create(:user, :invited)
      end

      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/organisation/utilisateurs/#{user.id}") }

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
