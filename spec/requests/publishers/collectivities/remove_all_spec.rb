# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Publishers::CollectivitiesController#remove_all" do
  subject(:request) do
    get "/editeurs/#{publisher.id}/collectivites/remove", as:, headers:, params:
  end

  let(:as)      { |e| e.metadata[:as] }
  let(:headers) { |e| e.metadata[:headers] }
  let(:params)  { |e| e.metadata.fetch(:params, { ids: ids }) }

  let!(:publisher)      { create(:publisher) }
  let!(:collectivities) { create_list(:collectivity, 3, publisher: publisher) }
  let!(:ids)            { collectivities.take(2).map(&:id) }

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

    context "when the publisher is the organization of the current user" do
      let(:publisher) { current_user.organization }

      it_behaves_like "it denies access to publisher user"
      it_behaves_like "it denies access to publisher admin"
    end
  end

  describe "responses" do
    before { sign_in_as(:super_admin) }

    context "with multiple ids" do
      it { expect(response).to have_http_status(:success) }
      it { expect(response).to have_content_type(:html) }
      it { expect(response).to have_html_body }
    end

    context "with `all` ids", params: { ids: "all" } do
      it { expect(response).to have_http_status(:success) }
    end

    context "with empty ids", params: { ids: [] } do
      it { expect(response).to have_http_status(:success) }
    end

    context "with unknown ids", params: { ids: %w[1 2] } do
      it { expect(response).to have_http_status(:success) }
    end

    context "with empty parameters", params: {} do
      it { expect(response).to have_http_status(:success) }
    end

    context "when the publisher is discarded" do
      before { publisher.discard }

      it { expect(response).to have_http_status(:gone) }
      it { expect(response).to have_content_type(:html) }
      it { expect(response).to have_html_body }
    end

    context "when the publisher is missing" do
      before { publisher.destroy }

      it { expect(response).to have_http_status(:not_found) }
      it { expect(response).to have_content_type(:html) }
      it { expect(response).to have_html_body }
    end
  end
end
