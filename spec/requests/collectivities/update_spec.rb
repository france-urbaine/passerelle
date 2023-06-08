# frozen_string_literal: true

require "rails_helper"

RSpec.describe "CollectivitiesController#update" do
  subject(:request) do
    patch "/collectivites/#{collectivity.id}", as:, headers:, params:
  end

  let(:as)      { |e| e.metadata[:as] }
  let(:headers) { |e| e.metadata[:headers] }
  let(:params)  { |e| e.metadata.fetch(:params, { collectivity: attributes }) }

  let!(:epci)         { create(:epci) }
  let!(:collectivity) { create(:collectivity, territory: epci, name: "Agglomération Pays Basque") }

  let(:attributes) do
    { name: "CA du Pays Basque" }
  end

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

    context "when the collectivity is the organization of the current user" do
      let(:collectivity) { current_user.organization }

      it_behaves_like "it denies access to collectivity user"
      it_behaves_like "it denies access to collectivity admin"
    end

    context "when the collectivity is owned by the current user's publisher organization" do
      let(:collectivity) { create(:collectivity, publisher: current_user.organization) }

      it_behaves_like "it allows access to publisher user"
      it_behaves_like "it allows access to publisher admin"
    end
  end

  describe "responses" do
    context "when signed in as super admin" do
      before { sign_in_as(:super_admin) }

      context "with valid attributes" do
        it { expect(response).to have_http_status(:see_other) }
        it { expect(response).to redirect_to("/collectivites") }

        it "updates the collectivity" do
          expect { request and collectivity.reload }
            .to  change(collectivity, :updated_at)
            .and change(collectivity, :name).to("CA du Pays Basque")
        end

        it "sets a flash notice" do
          expect(flash).to have_flash_notice.to eq(
            type:  "success",
            title: "Les modifications ont été enregistrées avec succés.",
            delay: 3000
          )
        end
      end

      context "when assigning another publisher in attributes" do
        let(:another_publisher) { create(:publisher) }
        let(:attributes)        { super().merge(publisher_id: another_publisher.id) }

        it { expect(response).to have_http_status(:see_other) }
        it { expect(response).to redirect_to("/collectivites") }

        it "updates the collectivity publisher" do
          expect { request and collectivity.reload }
            .to  change(collectivity, :updated_at)
            .and change(collectivity, :publisher).to(another_publisher)
        end
      end

      context "with invalid attributes" do
        let(:attributes) { super().merge(name: "") }

        it { expect(response).to have_http_status(:unprocessable_entity) }
        it { expect(response).to have_content_type(:html) }
        it { expect(response).to have_html_body }
        it { expect { request and collectivity.reload }.not_to change(collectivity, :updated_at) }
        it { expect { request and collectivity.reload }.not_to change(collectivity, :name) }
      end

      context "with empty parameters", params: {} do
        it { expect(response).to have_http_status(:see_other) }
        it { expect(response).to redirect_to("/collectivites") }
        it { expect(flash).to have_flash_notice }
        it { expect { request and collectivity.reload }.not_to change(collectivity, :updated_at) }
      end

      context "when the collectivity is discarded" do
        before { collectivity.discard }

        it { expect(response).to have_http_status(:gone) }
        it { expect(response).to have_content_type(:html) }
        it { expect(response).to have_html_body }
      end

      context "when the collectivity is missing" do
        before { collectivity.destroy }

        it { expect(response).to have_http_status(:not_found) }
        it { expect(response).to have_content_type(:html) }
        it { expect(response).to have_html_body }
      end

      context "with referrer header", headers: { "Referer" => "http://example.com/other/path" } do
        it { expect(response).to have_http_status(:see_other) }
        it { expect(response).to redirect_to("/collectivites") }
        it { expect(flash).to have_flash_notice }
      end

      context "with redirect parameter" do
        let(:params) { super().merge(redirect: "/other/path") }

        it { expect(response).to have_http_status(:see_other) }
        it { expect(response).to redirect_to("/other/path") }
        it { expect(flash).to have_flash_notice }
      end
    end

    context "when signed in as a publisher, owner of the collectivity" do
      before { sign_in_as(organization: collectivity.publisher) }

      context "with valid attributes" do
        it { expect(response).to have_http_status(:see_other) }
        it { expect(response).to redirect_to("/collectivites") }
        it { expect { request and collectivity.reload }.to change(collectivity, :updated_at) }
      end

      context "when assigning another publisher in attributes" do
        let(:another_publisher) { create(:publisher) }
        let(:attributes)        { super().merge(publisher_id: another_publisher.id) }

        it { expect(response).to have_http_status(:see_other) }
        it { expect(response).to redirect_to("/collectivites") }

        it "ignores the attribute" do
          expect { request and collectivity.reload }
            .to  change(collectivity, :updated_at)
            .and not_change(collectivity, :publisher)
        end
      end
    end
  end
end
