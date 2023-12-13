# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin::Publishers::UsersController#index" do
  subject(:request) do
    get "/admin/editeurs/#{publisher.id}/utilisateurs", as:, headers:, params:, xhr:
  end

  let(:as)      { |e| e.metadata[:as] }
  let(:headers) { |e| e.metadata[:headers] }
  let(:params)  { |e| e.metadata[:params] }
  let(:xhr)     { |e| e.metadata[:xhr] }

  let!(:publisher) { create(:publisher) }
  let!(:users) do
    [
      create(:user, :discarded, organization: publisher),
      create(:user, :discarded),
      create(:user),
      create(:user, organization: publisher)
    ]
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

    context "when the publisher is the current organization" do
      let(:publisher) { current_user.organization }

      it_behaves_like "it denies access to publisher user"
      it_behaves_like "it denies access to publisher admin"
    end
  end

  describe "responses" do
    before { sign_in_as(:super_admin) }

    context "when requesting HTML" do
      context "when the publisher is accessible" do
        it { expect(response).to have_http_status(:see_other) }
        it { expect(response).to redirect_to("/admin/editeurs/#{publisher.id}") }
      end

      context "when the publisher is discarded" do
        before { publisher.discard }

        it { expect(response).to have_http_status(:gone) }
        it { expect(response).to have_content_type(:html) }
        it { expect(response).to have_html_body.to have_text("Cet éditeur est en cours de suppression.") }
      end

      context "when the publisher is missing" do
        before { publisher.destroy }

        it { expect(response).to have_http_status(:not_found) }
        it { expect(response).to have_content_type(:html) }
        it { expect(response).to have_html_body.to have_text("Cet éditeur n'a pas été trouvé ou n'existe plus.") }
      end
    end

    context "when requesting Turbo-Frame", :xhr, headers: { "Turbo-Frame" => "datatable-users" } do
      it { expect(response).to have_http_status(:success) }
      it { expect(response).to have_content_type(:html) }
      it { expect(response).to have_html_body.with_turbo_frame("datatable-users") }

      it "returns only kept users associated to the publisher" do
        aggregate_failures do
          expect(response).to have_html_body.not_to have_text(users[0].name)
          expect(response).to have_html_body.not_to have_text(users[1].name)
          expect(response).to have_html_body.not_to have_text(users[2].name)
          expect(response).to have_html_body.to     have_text(users[3].name)
        end
      end

      context "when the publisher is discarded" do
        before { publisher.discard }

        it { expect(response).to have_http_status(:gone) }
        it { expect(response).to have_content_type(:html) }
        it { expect(response).to have_html_body.to have_text("Cet éditeur est en cours de suppression.") }
      end

      context "when the publisher is missing" do
        before { publisher.destroy }

        it { expect(response).to have_http_status(:not_found) }
        it { expect(response).to have_content_type(:html) }
        it { expect(response).to have_html_body.to have_text("Cet éditeur n'a pas été trouvé ou n'existe plus.") }
      end
    end

    context "when requesting autocompletion", :xhr, headers: { "Accept-Variant" => "autocomplete" } do
      it { expect(response).to have_http_status(:not_implemented) }
      it { expect(response).to have_content_type(:html) }
      it { expect(response).to have_html_body }
    end
  end
end
