# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Publishers::UsersController#remove_all" do
  subject(:request) do
    get "/editeurs/#{publisher.id}/utilisateurs/remove", as:, params:
  end

  let(:as)     { |e| e.metadata[:as] }
  let(:params) { |e| e.metadata.fetch(:params, { ids: ids }) }

  let!(:publisher) { create(:publisher) }
  let!(:users)     { create_list(:user, 3, organization: publisher) }
  let!(:ids)       { users.take(2).map(&:id) }

  context "when requesting HTML" do
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

    context "when publisher is discarded" do
      let(:publisher) { create(:publisher, :discarded) }

      it { expect(response).to have_http_status(:gone) }
      it { expect(response).to have_content_type(:html) }
      it { expect(response).to have_html_body }
    end

    context "when publisher is missing" do
      let(:publisher) { Publisher.new(id: Faker::Internet.uuid) }

      it { expect(response).to have_http_status(:not_found) }
      it { expect(response).to have_content_type(:html) }
      it { expect(response).to have_html_body }
    end
  end

  context "when requesting JSON", as: :json do
    it { expect(response).to have_http_status(:not_acceptable) }
    it { expect(response).to have_content_type(:json) }
    it { expect(response).to have_empty_body }
  end
end
