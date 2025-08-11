# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Users::UserSettingsController#update" do
  subject(:request) do
    put "/compte/parametres", as:, headers:, params:
  end

  let(:as)      { |e| e.metadata[:as] }
  let(:headers) { |e| e.metadata[:headers] }
  let(:params)  { |e| e.metadata.fetch(:params, { user: updated_attributes }) }

  let!(:user) { create(:user, first_name: "Guillaume", last_name: "Debailly") }

  let(:updated_attributes) do
    { first_name: "Paul", last_name: "Lefebvre" }
  end

  it_behaves_like "it requires to be signed in in HTML"
  it_behaves_like "it requires to be signed in in JSON"
  it_behaves_like "it responds with not acceptable in JSON when signed in"

  it_behaves_like "it allows access to publisher user"
  it_behaves_like "it allows access to publisher admin"
  it_behaves_like "it allows access to DDFIP user"
  it_behaves_like "it allows access to DDFIP admin"
  it_behaves_like "it allows access to collectivity user"
  it_behaves_like "it allows access to collectivity admin"
  it_behaves_like "it allows access to super admin"

  context "when signed in" do
    before { sign_in(user, reload_tracked_fields: true) }

    context "with valid attributes" do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/compte/parametres") }

      it "updates the curent user" do
        expect { request and user.reload }
          .to  change(user, :updated_at)
          .and change(user, :name).to("Paul Lefebvre")
      end

      it "sets a flash notice" do
        request
        expect(flash).to have_flash_notice.to eq(
          scheme: "success",
          header: "Les modifications ont été enregistrées avec succés.",
          delay:  3000
        )
      end
    end

    context "when updating email" do
      let(:updated_attributes) do
        { email: "paul.lefebvre@legende.fr", current_password: user.password }
      end

      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/compte/parametres") }

      it "updates the curent user" do
        expect { request and user.reload }
          .to  change(user, :updated_at)
          .and change(user, :unconfirmed_email).to("paul.lefebvre@legende.fr")
          .and not_change(user, :email)
      end

      it "sets a flash notice" do
        request
        expect(flash).to have_flash_notice.to eq(
          scheme: "success",
          header: "Les modifications ont été enregistrées avec succés.",
          delay:  3000
        )
      end

      it "delivers notifications about change to new and old user's addresses" do
        expect { request }
          .to have_sent_emails.by(2)
          .and have_sent_email.with_subject("Modification de votre adresse e-mail sur Passerelle").to("paul.lefebvre@legende.fr")
          .and have_sent_email.with_subject("Modification de votre adresse e-mail sur Passerelle").to(user.email)
      end
    end

    context "when updating email without current password" do
      let(:updated_attributes) do
        { email: "paul.lefebvre@legende.fr" }
      end

      it { expect(response).to have_http_status(:unprocessable_content) }
      it { expect(response).to have_media_type(:html) }
      it { expect(response).to have_html_body }

      it "doesn't update the curent user" do
        expect { request and user.reload }
          .to  not_change(user, :updated_at)
          .and not_change(user, :unconfirmed_email)
          .and not_change(user, :email)
      end
    end

    context "when updating password" do
      let(:updated_attributes) do
        password = Devise.friendly_token
        { password: password, password_confirmation: password, current_password: user.password }
      end

      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/compte/parametres") }

      it "updates the curent user" do
        expect { request and user.reload }
          .to  change(user, :updated_at)
          .and change(user, :encrypted_password)
      end

      it "sets a flash notice" do
        request
        expect(flash).to have_flash_notice.to eq(
          scheme: "success",
          header: "Les modifications ont été enregistrées avec succés.",
          delay:  3000
        )
      end

      it "delivers a notification about change to user" do
        expect { request && perform_enqueued_jobs }
          .to have_sent_emails.by(1)
          .and have_sent_email.with_subject("Modification de votre mot de passe sur Passerelle").to(user.email)
      end
    end

    context "when updating password without current password" do
      let(:updated_attributes) do
        password = Devise.friendly_token
        { password: password, password_confirmation: password }
      end

      it { expect(response).to have_http_status(:unprocessable_content) }
      it { expect(response).to have_media_type(:html) }
      it { expect(response).to have_html_body }

      it "doesn't update the curent user" do
        expect { request and user.reload }
          .to  not_change(user, :updated_at)
          .and not_change(user, :encrypted_password)
      end
    end

    context "with empty parameters", params: {} do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/compte/parametres") }
      it { expect(flash).to have_flash_notice }
      it { expect { request and user.reload }.not_to change(user, :updated_at) }
    end
  end
end
