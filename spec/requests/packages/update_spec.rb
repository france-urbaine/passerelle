# frozen_string_literal: true

require "rails_helper"

RSpec.describe "PackagesController#update" do
  subject(:request) do
    patch "/paquets/#{package.id}", as:, headers:, params:
  end

  let(:as)      { |e| e.metadata[:as] }
  let(:headers) { |e| e.metadata[:headers] }
  let(:params)  { |e| e.metadata.fetch(:params, { package: attributes }) }

  let!(:package) { create(:package) }

  let(:attributes) do
    { due_on: "2023-06-07" }
  end

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
      let(:package) { create(:package, :packed_through_web_ui, collectivity: current_user.organization) }

      it_behaves_like "it allows access to collectivity user"
      it_behaves_like "it allows access to collectivity admin"
    end

    context "when package has been transmitted by current user collectivity" do
      let(:package) { create(:package, :transmitted_through_web_ui, collectivity: current_user.organization) }

      it_behaves_like "it denies access to collectivity user"
      it_behaves_like "it denies access to collectivity admin"
    end

    context "when package has been packed by current user publisher" do
      let(:package) { create(:package, :packed_through_api, publisher: current_user.organization) }

      it_behaves_like "it allows access to publisher user"
      it_behaves_like "it allows access to publisher admin"
    end

    context "when package has been transmitted by current user publisher" do
      let(:package) { create(:package, :transmitted_through_api, publisher: current_user.organization) }

      it_behaves_like "it denies access to publisher user"
      it_behaves_like "it denies access to publisher admin"
    end

    context "when package has been transmitted to current user DDFIP" do
      let(:package) { create(:package, :transmitted_to_ddfip, ddfip: current_user.organization) }

      it_behaves_like "it denies access to DDFIP admin"
      it_behaves_like "it denies access to DDFIP user"
    end
  end

  describe "responses" do
    context "when signed in as a collectivity user" do
      before { sign_in_as(organization: package.collectivity) }

      context "with valid attributes" do
        it { expect(response).to have_http_status(:see_other) }
        it { expect(response).to redirect_to("/paquets/#{package.id}") }

        it "updates the package" do
          expect { request and package.reload }
            .to  change(package, :updated_at)
            .and change(package, :due_on).to(Date.parse("2023-06-07"))
        end

        it "sets a flash notice" do
          expect(flash).to have_flash_notice.to eq(
            type:  "success",
            title: "Les modifications ont été enregistrées avec succés.",
            delay: 3000
          )
        end
      end

      # Skip this context: #
      # The only permitted attribute is :due_on and it transform any unexpected
      # value to nil, which is a valid value.
      #
      # context "with invalid attributes" do
      #   ....
      # end

      context "with empty parameters", params: {} do
        it { expect(response).to have_http_status(:see_other) }
        it { expect(response).to redirect_to("/paquets/#{package.id}") }
        it { expect(flash).to have_flash_notice }
        it { expect { request and package.reload }.not_to change(package, :updated_at) }
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

      context "with referrer header", headers: { "Referer" => "http://example.com/other/path" } do
        it { expect(response).to have_http_status(:see_other) }
        it { expect(response).to redirect_to("/paquets/#{package.id}") }
        it { expect(flash).to have_flash_notice }
      end

      context "with redirect parameter" do
        let(:params) { super().merge(redirect: "/other/path") }

        it { expect(response).to have_http_status(:see_other) }
        it { expect(response).to redirect_to("/other/path") }
        it { expect(flash).to have_flash_notice }
      end
    end
  end
end
