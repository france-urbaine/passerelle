# frozen_string_literal: true

require "rails_helper"

RSpec.describe "PackagesController#show" do
  subject(:request) do
    get "/paquets/#{package.id}", as:, headers:, params:
  end

  let(:as)      { |e| e.metadata[:as] }
  let(:headers) { |e| e.metadata[:headers] }
  let(:params)  { |e| e.metadata[:params] }

  let!(:package) { create(:package) }

  describe "authorizations" do
    it_behaves_like "it requires authorization in HTML"
    it_behaves_like "it requires authorization in JSON"
    it_behaves_like "it responds with not acceptable in JSON when signed in"

    it_behaves_like "it denies access to publisher user"
    it_behaves_like "it denies access to publisher admin"
    it_behaves_like "it denies access to DDFIP user"
    it_behaves_like "it denies access to DDFIP admin"
    it_behaves_like "it denies access to collectivity user"
    it_behaves_like "it denies access to collectivity admin"

    context "when package has been packed by current user collectivity" do
      let(:package) { create(:package, collectivity: current_user.organization) }

      it_behaves_like "it allows access to collectivity user"
      it_behaves_like "it allows access to collectivity admin"
    end

    context "when package has been packed by current user publisher" do
      let(:package) { create(:package, publisher: current_user.organization) }

      it_behaves_like "it allows access to publisher user"
      it_behaves_like "it allows access to publisher admin"
    end

    context "when package has been transmitted to current user DDFIP" do
      let(:package) { create(:package, :transmitted_to_ddfip, ddfip: current_user.organization) }

      it_behaves_like "it denies access to DDFIP user"
      it_behaves_like "it allows access to DDFIP admin"
    end
  end

  describe "responses" do
    context "when signed in as a collectivity user" do
      let(:collectivity) { create(:collectivity) }
      let(:package)      { create(:package, collectivity: collectivity) }

      before { sign_in_as(organization: collectivity) }

      context "when the package is active" do
        it { expect(response).to have_http_status(:success) }
        it { expect(response).to have_content_type(:html) }
        it { expect(response).to have_html_body }
      end

      context "when the package is transmitted" do
        before { package.touch(:transmitted_at) }

        it { expect(response).to have_http_status(:success) }
        it { expect(response).to have_content_type(:html) }
        it { expect(response).to have_html_body }
      end

      context "when the package is discarded" do
        before { package.discard }

        it { expect(response).to have_http_status(:gone) }
        it { expect(response).to have_content_type(:html) }
        it { expect(response).to have_html_body }
      end

      context "when the package is missing" do
        before { package.destroy }

        it { expect(response).to have_http_status(:not_found) }
        it { expect(response).to have_content_type(:html) }
        it { expect(response).to have_html_body }
      end
    end
  end
end
