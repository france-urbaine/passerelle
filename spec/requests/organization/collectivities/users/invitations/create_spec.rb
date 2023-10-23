# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Organization::Collectivities::Users::InvitationsController#create" do
  subject(:request) do
    post "/organisation/collectivites/#{collectivity.id}/utilisateurs/#{user.id}/invitation", as:, headers:, params:
  end

  let(:as)      { |e| e.metadata[:as] }
  let(:headers) { |e| e.metadata[:headers] }
  let(:params)  { |e| e.metadata[:params] }

  let!(:publisher)    { create(:publisher) }
  let!(:collectivity) { create(:collectivity, publisher: publisher, allow_publisher_management: true) }

  let!(:user) do
    Timecop.freeze(1.month.ago) do
      create(:user, :invited, :unconfirmed, organization: collectivity)
    end
  end

  describe "authorizations" do
    it_behaves_like "it requires to be signed in in HTML"
    it_behaves_like "it requires to be signed in in JSON"
    it_behaves_like "it responds with not acceptable in JSON when signed in"

    it_behaves_like "it denies access to DDFIP user"
    it_behaves_like "it denies access to DDFIP admin"
    it_behaves_like "it denies access to DDFIP super admin"
    it_behaves_like "it denies access to collectivity user"
    it_behaves_like "it denies access to collectivity admin"
    it_behaves_like "it denies access to collectivity super admin"

    it_behaves_like "it responds with not found to publisher user"
    it_behaves_like "it responds with not found to publisher admin"
    it_behaves_like "it responds with not found to publisher super admin"

    context "when the collectivity is the current organization" do
      let(:collectivity) { current_user.organization }

      it_behaves_like "it denies access to collectivity user"
      it_behaves_like "it denies access to collectivity admin"
      it_behaves_like "it denies access to collectivity super admin"
    end

    context "when the collectivity is owned by but didn't allow to be managed by the current publisher" do
      let(:collectivity) { create(:collectivity, publisher: current_user.organization, allow_publisher_management: false) }

      it_behaves_like "it denies access to publisher user"
      it_behaves_like "it denies access to publisher admin"
      it_behaves_like "it denies access to publisher super admin"
    end

    context "when the collectivity is owned by and allowed to be managed by the current publisher" do
      let(:collectivity) { create(:collectivity, publisher: current_user.organization, allow_publisher_management: true) }

      it_behaves_like "it allows access to publisher user"
      it_behaves_like "it allows access to publisher admin"
      it_behaves_like "it allows access to publisher super admin"
    end

    context "when the collectivity is likely to send reports to current DDFIP" do
      let(:commune)      { create(:commune, departement: current_user.organization.departement) }
      let(:collectivity) { create(:collectivity, territory: commune) }

      it_behaves_like "it denies access to DDFIP user"
      it_behaves_like "it denies access to DDFIP admin"
      it_behaves_like "it denies access to DDFIP super admin"
    end
  end

  describe "responses" do
    before { sign_in_as(:organization_admin, organization: publisher) }

    context "when user's invitation expired" do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/organisation/collectivites/#{collectivity.id}/utilisateurs/#{user.id}") }

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

      it "delivers confirmation instructions" do
        expect { request }
          .to have_sent_emails.by(1)
          .and have_sent_email.with_subject("Votre inscription sur Passerelle")
      end
    end

    context "when user's invitation is still valid" do
      let(:user) do
        create(:user, :invited, :unconfirmed, organization: collectivity)
      end

      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/organisation/collectivites/#{collectivity.id}/utilisateurs/#{user.id}") }

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

      it "delivers confirmation instructions" do
        expect { request }
          .to have_sent_emails.by(1)
          .and have_sent_email.with_subject("Votre inscription sur Passerelle")
      end
    end

    context "when user is already confirmed" do
      let(:user) do
        create(:user, :invited, organization: collectivity)
      end

      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/organisation/collectivites/#{collectivity.id}/utilisateurs/#{user.id}") }

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
